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
			Button(watchable.isFavorite ? "Remove from Favorites" : "Add to Favorites", action: toggleFavorite)
			Button(watchable.isPinned ? "Unpin" : "Pin", action: togglePinned)
			
			Divider()
			
			Button("Remove from Library", action: removeFromLibrary)
			
			Divider()
			
			Button("Open in Subler") { }
			Button("Play with default Player") { }
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
}
