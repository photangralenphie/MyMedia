//
//  VideoPlayerView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 01.04.25.
//

import SwiftUI
import AVKit
import SwiftData

struct VideoPlayerView: View {
	
	@State private var queue: [any IsWatchable]
	@State private var currentWatchable: (any IsWatchable)?
	@State private var player: AVPlayer
	
	@Environment(\.dismiss) private var dismiss
	
	@AppStorage(PreferenceKeys.autoPlay) private var autoPlay: Bool = true
	
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
			self.player = .init()
			return
		}
		
		let avItems = initQueue.map{ AVPlayerItem(url: $0.url) }
		let initCurrentWatchable = initQueue.removeFirst()
		self.player = AVQueuePlayer(items: avItems)
		
		self.queue = initQueue
		self.currentWatchable = initCurrentWatchable
	}
	
	var body: some View {
		VideoPlayer(player: player)
			.edgesIgnoringSafeArea(.all)
			.onAppear {
				if autoPlay {
					player.actionAtItemEnd = .advance
				}
				player.play()
			}
			.onReceive(NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)) { _ in
				videoDidFinish()
			}
			.onDisappear {
				currentWatchable?.progressMinutes = Int(player.currentItem?.currentTime().seconds ?? 0) / 60
			}
	}
	
	func videoDidFinish() {
		currentWatchable?.progressMinutes = currentWatchable?.durationMinutes ?? 0
		currentWatchable?.isWatched = true
		
		if(queue.isEmpty) {
			dismiss()
			return
		}
			
		currentWatchable = queue.removeFirst()
	}
}
