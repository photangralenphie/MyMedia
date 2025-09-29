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
	
	@State public var mediaItem: any MediaItem
	public var applyShortcuts: Bool
	let onDelete: () -> Void

	@Query(sort: \MediaCollection.title) private var collections: [MediaCollection]
	
	@Environment(\.modelContext) private var moc
	@Environment(\.mediaContext) private var mediaContext
	
    var body: some View {
		Button(mediaItem.isWatched ? "Mark Unwatched" : "Mark Watched", systemImage: mediaItem.isWatched ? "eye.slash" : "eye") { mediaItem.toggleWatched() }
			.keyboardShortcut(applyShortcuts ? KeyboardShortcut("w", modifiers: .command) : nil)
		
		if !(mediaItem is Episode) {
			Button(mediaItem.isFavorite ? "Remove from Favourites" : "Add to Favourites", systemImage: mediaItem.isFavorite ? "star.slash" : "star") { mediaItem.toggleFavorite() }
				.keyboardShortcut(applyShortcuts ? KeyboardShortcut("f", modifiers: [.shift, .command]) : nil)
			
			Button(mediaItem.isPinned ? "Unpin" : "Pin", systemImage: mediaItem.isPinned ? "pin.slash" : "pin") { mediaItem.togglePinned() }
				.keyboardShortcut(applyShortcuts ? KeyboardShortcut("p", modifiers: .command) : nil)
			
			if !collections.isEmpty {
				Menu("Add to Collection", systemImage: SystemImages.collections) {
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
		
		Button("Remove from Library", systemImage: "trash", action: removeFromLibrary)
			.keyboardShortcut(applyShortcuts ? KeyboardShortcut(.delete, modifiers: .command) : nil)
		
		if case let .collection(collection) = mediaContext {
			Button("Remove from Collection", systemImage: "trash") {
				withAnimation { collection.removeMediaItem(mediaItem) }
			}
		}
		
		Divider()
		
		if let isWatchable = mediaItem as? any IsWatchable {
			if isSublerInstalled() {
				Button("Open in Subler", systemImage: "square.and.arrow.up") { isWatchable.openInSubler() }
			}
		
			Button("Show in Finder", systemImage: "finder") { isWatchable.openInFinder() }
		}
		
		
		Button("Update Metadata", systemImage: "arrow.trianglehead.counterclockwise", action: reImportToLibrary)
		
		if case let tvShow as TvShow = mediaItem, tvShow.episodes.count == 0 {
			// Show button only if tvShow has episodes
		} else {
			Button("Play with default Player", systemImage: "play.rectangle.on.rectangle.fill") { mediaItem.playWithDefaultPlayer() }
				.keyboardShortcut(applyShortcuts ? KeyboardShortcut("p", modifiers: [.command, .shift]) : nil)
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
		let currentMediaItem = mediaItem
		Task {
			let mediaImporter = MediaImporter(modelContainer: moc.container)
			do {
				try await mediaImporter.updateMediaItem(mediaItem: currentMediaItem)
			} catch let importError as ImportError {
				MediaImporter.showImportError(importError)
			}
		}
	}
}
