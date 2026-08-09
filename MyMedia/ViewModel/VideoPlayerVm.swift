//
//  VideoPlayerVm.swift
//  MyMedia
//
//  Created by Jonas Helmer on 19.02.26.
//

import SwiftUI
import AVKit
import SwiftData
import MediaPlayer
import Observation

@MainActor
@Observable
final class VideoPlayerVm {
	@ObservationIgnored
	private let context: ModelContext

	var errorText: String = ""
	var showErrorSheet: Bool = false
	var playType: PlayType = .play

	@ObservationIgnored
	private var queue: [any IsWatchable] = []
	@ObservationIgnored
	private var currentWatchable: (any IsWatchable)?
	@ObservationIgnored
	let player = AVQueuePlayer()
	@ObservationIgnored
	private var currentNowPlayingWatchableId = UUID()
	@ObservationIgnored
	private let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()

	init(context: ModelContext) {
		self.context = context
	}

	func setupPlayback(playAction: PlayAction, autoPlay: Bool) {
		// Rebuilding the scene can trigger this more than once; make setup idempotent.
		player.pause()
		player.removeAllItems()
		queue = []
		currentWatchable = nil

		for id in playAction.identifiers {
			if let watchable = context.model(for: id) as? (any IsWatchable) {
				queue.append(watchable)
			}
		}

		if queue.isEmpty {
			currentWatchable = nil
			queue = []
			playType = .play
			return
		}

		playType = playAction.playType
		createPlaybackQueue(autoPlay: autoPlay)
	}

	func videoDidFinish() -> Bool {
		if var currentWatchable {
			let duration = currentWatchable.durationMinutes
			currentWatchable.progressMinutes = duration
			currentWatchable.isWatched = true
			currentWatchable.url?.stopAccessingSecurityScopedResource()
		}

		if queue.isEmpty {
			return true
		}

		currentWatchable = queue.removeFirst()
		return false
	}

	func onDisappear() {
		currentWatchable?.progressMinutes = Int(player.currentItem?.currentTime().seconds ?? 0) / 60
		queue.forEach { $0.url?.stopAccessingSecurityScopedResource() }
		nowPlayingInfoCenter.nowPlayingInfo = nil
	}

	func updateNowPlayingInfo() {
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
			nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = String(localized: "Season \(episode.season), Episode \(episode.episode)")
		}
		nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
	}

	private func createPlaybackQueue(autoPlay: Bool) {
		if queueHasProtectedFiles() {
			playQueueWithQuickTime()
			return
		}

		let avItems: [AVPlayerItem] = queue.compactMap {
			guard let url = $0.url, url.startAccessingSecurityScopedResource() else { return nil }
			return AVPlayerItem(url: url)
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

		if playType == .resume || playType == .resumeCurrentEpisode {
			let progressSeconds = Double((currentWatchable?.progressMinutes ?? 0) * 60)
			player.seek(to: CMTime(seconds: progressSeconds, preferredTimescale: 1))
		}
	}

	private func queueHasProtectedFiles() -> Bool {
		for item in queue {
			guard let url = item.url, url.startAccessingSecurityScopedResource() else { return false }
			defer { url.stopAccessingSecurityScopedResource() }
			let asset = AVURLAsset(url: url)
			
			// There is no other way for now to check if the file has Apple DRM
			// The suggested load(.hasProtectedContent) does not work and just crashes the app.
			// So we use the deprecated function for now until another way comes up.
			
			if asset.hasProtectedContent { return true }
		}

		return false
	}

	private func playQueueWithQuickTime() {
		let quickTimeQueue = queue
			.compactMap { $0.url }
			.filter { $0.startAccessingSecurityScopedResource() }

		let config = NSWorkspace.OpenConfiguration()
		config.activates = true

		let message = String(localized: "Media is protected and cannot be played directly. Opening with QuickTime.")
		guard let quickTimeURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "com.apple.QuickTimePlayerX") else {
			errorText = message + String(localized: " QuickTime was not found.")
			return
		}

		NSWorkspace.shared.open(quickTimeQueue, withApplicationAt: quickTimeURL, configuration: config) { _, error in
			Task { @MainActor in
				if error != nil {
					self.errorText = message + String(localized: "Playing with QuickTime failed.")
				}
			}
		}
	}
}
