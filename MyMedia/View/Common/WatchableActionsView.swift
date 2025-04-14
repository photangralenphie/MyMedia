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
		Menu("Actions") {
			Button(watchable.isWatched ? "Mark Unwatched" : "Mark Watched", action: toggleWatched)
				.keyboardShortcut("w", modifiers: .command)
			
			Button(watchable.isFavorite ? "Remove from Favorites" : "Add to Favorites", action: toggleFavorite)
				.keyboardShortcut("f", modifiers: [.shift, .command])
			
			Button(watchable.isPinned ? "Unpin" : "Pin", action: togglePinned)
				.keyboardShortcut("p", modifiers: .command)
			
			Divider()
			
			Button("Remove from Library", action: removeFromLibrary)
				.keyboardShortcut(.delete, modifiers: .command)
			
			Divider()
			
			Button("Open in Subler") { }
			
			if case let tvshow as TvShow = watchable, tvshow.episodes.count == 0 {
				// Show button only if tvshow has episodes
			} else {
				Button("Play with default Player", action: playWithDefaultPlayer)
					.keyboardShortcut("p", modifiers: [.command, .shift])
			}
		}
    }
	
	func removeFromLibrary() {
		switch watchable {
			case let movie as Movie:
				moc.delete(movie)
			case let tvShow as TvShow:
				moc.delete(tvShow)
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
}
