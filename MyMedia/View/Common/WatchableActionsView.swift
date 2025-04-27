//
//  WatchableActionsView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 10.04.25.
//

import SwiftUI

struct WatchableActionsView: View {
	
	@State public var watchable: any Watchable
	@Environment(\.modelContext) private var moc
	
	let onDelete: () -> Void
	
    var body: some View {
		Button(watchable.isWatched ? "Mark Unwatched" : "Mark Watched", action: toggleWatched)
			.keyboardShortcut("w", modifiers: .command)
		
		if !(watchable is TvShow) {
			Button(watchable.isFavorite ? "Remove from Favourites" : "Add to Favourites", action: toggleFavorite)
				.keyboardShortcut("f", modifiers: [.shift, .command])
			
			Button(watchable.isPinned ? "Unpin" : "Pin", action: togglePinned)
				.keyboardShortcut("p", modifiers: .command)
		}
		
		Divider()
		
		Button("Remove from Library", action: removeFromLibrary)
			.keyboardShortcut(.delete, modifiers: .command)
		
		Divider()
		
		if isSublerInstalled() {
			if !(watchable is TvShow) {
				Button("Open in Subler") { openInSubler(fileUrl: watchable.url) }
			}
		}
		
		if case let tvShow as TvShow = watchable, tvShow.episodes.count == 0 {
			// Show button only if tvShow has episodes
		} else {
			Button("Play with default Player", action: playWithDefaultPlayer)
				.keyboardShortcut("p", modifiers: [.command, .shift])
		}
    }
	
	func removeFromLibrary() {
		switch watchable {
			case let movie as Movie:
				moc.delete(movie)
			case let tvShow as TvShow:
				moc.delete(tvShow)
			case let episode as Episode:
				moc.delete(episode)
			default:
				break
		}
		
		onDelete()
	}
	
	func toggleWatched() {
		withAnimation {
			watchable.isWatched.toggle()
		}
	}
	
	func toggleFavorite() {
		withAnimation {
			watchable.isFavorite.toggle()
		}
	}
	
	func togglePinned() {
		withAnimation {
			watchable.isPinned.toggle()
		}
	}
	
	func playWithDefaultPlayer() {
		NSWorkspace.shared.open(watchable.url)
	}
	
	func isSublerInstalled() -> Bool {
		let bundleIdentifier = "org.galad.Subler"
		
		if let urls = LSCopyApplicationURLsForBundleIdentifier(bundleIdentifier as CFString, nil)?.takeRetainedValue() as? [URL] {
			return !urls.isEmpty
		}
		return false
	}
	
	func openInSubler(fileUrl: URL) {
		let appPath = "/Applications/Subler.app"

		let process = Process()
		process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
		process.arguments = ["-a", appPath, fileUrl.path]
		
		do {
			try process.run()
		} catch {
			print("Failed to open file: \(error)")
		}
	}
}
