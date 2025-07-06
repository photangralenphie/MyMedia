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
import MediaPlayer
@_spi(Advanced) import SwiftUIIntrospect

struct VideoPlayerView: View {
	
	@State private var errorText: String = ""
	@State private var showErrorSheet: Bool = false
	
	@State private var queue: [any IsWatchable]
	@State private var currentWatchable: (any IsWatchable)?
	private var player = AVQueuePlayer()

	@State private var currentNowPlayingWatchableId = UUID()
	let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
	
	@Environment(\.dismiss) private var dismiss
	
	@AppStorage(PreferenceKeys.autoPlay) private var autoPlay: Bool = true
	@AppStorage(PreferenceKeys.playerStyle) private var playerStyle: AVPlayerViewControlsStyle = .floating
	
	init(ids: [PersistentIdentifier], context: ModelContext) {
		var initQueue: [any IsWatchable] = []
		for id in ids {
			let object = context.model(for: id)
			if(object is (any IsWatchable)) {
				initQueue.append(object as! (any IsWatchable))
			}
		}
		
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
			.onAppear(perform: createPlaybackQueue)
			.onReceive(NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)) { _ in
				videoDidFinish()
			}
			.onReceive(NotificationCenter.default.publisher(for: .AVPlayerItemTimeJumped, object: player.currentItem)) { _ in
				updateNowPlayingInfo()
			}
			.onDisappear(perform: onDisappear)
			.introspect(.videoPlayer, on: .macOS(.v15...)) { AVPlayerView in
				AVPlayerView.allowsPictureInPicturePlayback = true
				AVPlayerView.controlsStyle = playerStyle
				AVPlayerView.showsFullScreenToggleButton = true
				AVPlayerView.showsSharingServiceButton = true
				AVPlayerView.showsTimecodes = true
			}
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
		
		for item in avItems {
			player.insert(item, after: nil)
		}

		if autoPlay {
			player.actionAtItemEnd = .advance
		}

		currentWatchable = queue.removeFirst()
		player.preventsDisplaySleepDuringVideoPlayback = true
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
	
	func onDisappear() {
		currentWatchable?.progressMinutes = Int(player.currentItem?.currentTime().seconds ?? 0) / 60
		queue.forEach { $0.url?.stopAccessingSecurityScopedResource() }
		nowPlayingInfoCenter.nowPlayingInfo = nil
	}

	private func updateNowPlayingInfo() {
		guard let currentWatchable else { return }
		if player.timeControlStatus != .playing { return }
		if currentWatchable.id == currentNowPlayingWatchableId { return }

		currentNowPlayingWatchableId = currentWatchable.id
		var nowPlayingInfo: [String: Any] = [:]
		nowPlayingInfo[MPMediaItemPropertyTitle] = currentWatchable.title

		if let imageData = currentWatchable.artwork, let image = NSImage(data: imageData) {
			// @Sendable: https://developer.apple.com/forums/thread/764874?answerId=810243022#810243022
			nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { @Sendable _ in image }
		}
		if let episode = currentWatchable as? Episode {
			nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = "Season \(episode.season) Episode \(episode.episode)"
		}
		nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
	}
}
