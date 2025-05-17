//
//  MediaItemActionsView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 10.04.25.
//

import SwiftUI
import AwesomeSwiftyComponents
import SwiftData

struct MediaItemActionsView: View {
	
	@Query(sort: \MediaCollection.title) private var collections: [MediaCollection]
	
	@State public var mediaItem: any MediaItem
	@Environment(\.modelContext) private var moc
	@State private var updateError: String? = nil
	
	let onDelete: () -> Void
	
    var body: some View {
		Button(mediaItem.isWatched ? "Mark Unwatched" : "Mark Watched") { mediaItem.toggleWatched() }
			.keyboardShortcut("w", modifiers: .command)
		
		if !(mediaItem is Episode) {
			Button(mediaItem.isFavorite ? "Remove from Favourites" : "Add to Favourites") { mediaItem.toggleFavorite() }
				.keyboardShortcut("f", modifiers: [.shift, .command])
			
			Button(mediaItem.isPinned ? "Unpin" : "Pin") { mediaItem.togglePinned() }
				.keyboardShortcut("p", modifiers: .command)
			
			if !collections.isEmpty {
				Menu("Add to Collection") {
					ForEach(collections) { collection in
						Button {
							collection.addMediaItem(mediaItem)
						} label: {
							if collection.isItemInCollection(mediaItem) {
								Label(collection.title, systemImage: "checkmark")
									.labelStyle(.titleAndIcon)
							} else {
								Text(collection.title)
							}
						}
					}
				}
			}
		}
		
		Divider()
		
		Button("Remove from Library", action: removeFromLibrary)
			.keyboardShortcut(.delete, modifiers: .command)
		
		Divider()
		
		if isSublerInstalled() {
			if let isWatchable = mediaItem as? any IsWatchable {
				Button("Open in Subler") { isWatchable.openInSubler() }
			}
		}
		
		Button("Re-import", systemImage: "arrow.trianglehead.counterclockwise", action: reImportToLibrary)
			.alert("An Error occurred while updating.", isPresented: $updateError.isNotNil()) {
				Button("Ok"){ updateError = nil }
			} message: {
				Text(updateError ?? "")
			}
		
		if case let tvShow as TvShow = mediaItem, tvShow.episodes.count == 0 {
			// Show button only if tvShow has episodes
		} else {
			Button("Play with default Player") { mediaItem.play(useInAppPlayer: false) }
				.keyboardShortcut("p", modifiers: [.command, .shift])
		}
    }
	
	func removeFromLibrary() {
		switch mediaItem {
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
	
	func isSublerInstalled() -> Bool {
		let bundleIdentifier = "org.galad.Subler"
		
		if let urls = LSCopyApplicationURLsForBundleIdentifier(bundleIdentifier as CFString, nil)?.takeRetainedValue() as? [URL] {
			return !urls.isEmpty
		}
		return false
	}
	
	func reImportToLibrary() {
		Task {
			let mediaImporter = MediaImporter(modelContainer: moc.container)
			do {
				try await mediaImporter.updateMediaItem(mediaItem: mediaItem)
			} catch(let importError) {
				updateError = importError.localizedDescription
			}
		}
	}
}
