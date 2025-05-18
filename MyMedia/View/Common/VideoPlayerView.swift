//
//  VideoPlayerView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 01.04.25.
//

import SwiftUI
import AVKit
import SwiftData
import AwesomeSwiftyComponents
import SwiftUIIntrospect

struct VideoPlayerView: View {
	
	@State private var errorText: String = ""
	@State private var showErrorSheet: Bool = false
	
	@State private var queue: [any IsWatchable]
	@State private var currentWatchable: (any IsWatchable)?
	private var player: AVQueuePlayer
	
	@Environment(\.dismiss) private var dismiss
	
	@AppStorage(PreferenceKeys.autoPlay) private var autoPlay: Bool = true
	@AppStorage(PreferenceKeys.playerStyle) private var playerStyle: AVPlayerViewControlsStyle = .floating
	
	@State private var activity: NSObjectProtocol?
	
	init(ids: [PersistentIdentifier], context: ModelContext) {
		var initQueue: [any IsWatchable] = []
		for id in ids {
			let object = context.model(for: id)
			if(object is (any IsWatchable)) {
				initQueue.append(object as! (any IsWatchable))
			}
		}

		self.player = .init()
		
		if initQueue.isEmpty {
			self.currentWatchable = nil
			self.queue = []
			return
		}
		
		self.queue = initQueue
	}
	
	var body: some View {
		VideoPlayer(player: player)
			.sheet(isPresented: $showErrorSheet){
				Text("error: \(errorText)")
			}
			.task { preventSleep() }
			.onAppear(perform: createPlaybackQueue)
			.onReceive(NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)) { _ in
				videoDidFinish()
			}
			.onDisappear(perform: ondisappear)
			.introspect(.videoPlayer, on: .macOS(.v15)) { AVPlayerView in
				AVPlayerView.allowsPictureInPicturePlayback = true
				AVPlayerView.controlsStyle = playerStyle
			}
	}
	
	func preventSleep() {
		activity = ProcessInfo.processInfo.beginActivity(
			options: [.idleSystemSleepDisabled, .idleDisplaySleepDisabled, .userInitiated],
			reason: "Keeps Mac awake during video playback"
		)
	}
	
	func createPlaybackQueue() {
		let avItems = queue.compactMap {
			if let url = $0.url {
				if url.startAccessingSecurityScopedResource() {
					let item = AVPlayerItem(url: url)
					return item
				}
			}
			return nil
		}
		
		currentWatchable = queue.removeFirst()
		
		for item in avItems {
			player.insert(item, after: nil)
		}

		if autoPlay {
			player.actionAtItemEnd = .advance
		}
		player.play()
	}
	
	func videoDidFinish() {
		currentWatchable?.progressMinutes = currentWatchable?.durationMinutes ?? 0
		currentWatchable?.isWatched = true
		currentWatchable?.url?.stopAccessingSecurityScopedResource()
		
		if(queue.isEmpty) {
			dismiss()
			return
		}
			
		currentWatchable = queue.removeFirst()
	}
	
	func ondisappear() {
		currentWatchable?.progressMinutes = Int(player.currentItem?.currentTime().seconds ?? 0) / 60
		if let activity = activity {
			ProcessInfo.processInfo.endActivity(activity)
		}
		queue.forEach { $0.url?.stopAccessingSecurityScopedResource() }
	}
}
