//
// Copyright © 2025 MyMedia.
// Licensed under the MIT License.
//

import SwiftData
import SwiftUI

struct MediaItemActionsView: View {
	@State private var mediaItem: any MediaItem
	public var applyShortcuts: Bool
	let onDelete: () -> Void

	@Query(sort: \MediaCollection.title) private var collections: [MediaCollection]

	@AppStorage(PreferenceKeys.useInAppPlayer) private var useInAppPlayer: Bool = true

	@Environment(\.modelContext) private var modelContext
	@Environment(\.openWindow) private var openWindow
	@Environment(\.mediaContext) private var mediaContext
	@Environment(CommandResource.self) private var commandResource

	init(mediaItem: any MediaItem, applyShortcuts: Bool, onDelete: @escaping () -> Void) {
		_mediaItem = State(initialValue: mediaItem)
		self.applyShortcuts = applyShortcuts
		self.onDelete = onDelete
	}

    var body: some View {
		Button(mediaItem.isWatched ? "Mark Unwatched" : "Mark Watched", systemImage: mediaItem.isWatched ? "eye.slash" : "eye") { mediaItem.toggleWatched() }
			.keyboardShortcut(applyShortcuts ? KeyboardShortcut("w", modifiers: .command) : nil)

		Button(mediaItem.isPinned ? "Unpin" : "Pin", systemImage: mediaItem.isPinned ? "pin.slash" : "pin") { mediaItem.togglePinned() }
			.keyboardShortcut(applyShortcuts ? KeyboardShortcut("p", modifiers: .command) : nil)

		if !(mediaItem is Episode) {
			Button(mediaItem.isFavorite ? "Remove from Favourites" : "Add to Favourites", systemImage: mediaItem.isFavorite ? "star.slash" : "star") { mediaItem.toggleFavorite() }
				.keyboardShortcut(applyShortcuts ? KeyboardShortcut("f", modifiers: [.shift, .command]) : nil)

			if !collections.isEmpty {
				Menu("Add to Collection", systemImage: Tabs.collections.systemImage) {
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

		if case let tvShow as TvShow = mediaItem, tvShow.episodes.isEmpty {
			// Show button only if tvShow has episodes
		} else {
			Button(useInAppPlayer ? "Play with default Player" : "Play with built-in Player", systemImage: "play.rectangle.on.rectangle.fill", action: playWithAlternatePlayer)
				.keyboardShortcut(applyShortcuts ? KeyboardShortcut("p", modifiers: [.command, .shift]) : nil)
		}

		if case let tvShow as TvShow = mediaItem {
			Button("Select Artwork", systemImage: "photo.badge.checkmark.fill") {
				commandResource.tvShowArtworkToEdit = tvShow
			}
		}
    }

	func removeFromLibrary() {
		MetadataUtil.delete(mediaItem, context: modelContext)
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
		guard let persistentModel = mediaItem as? any PersistentModel else { return }
		let identifier = persistentModel.persistentModelID
		let modelContainer = modelContext.container

		_ = Task {
			let mediaImporter = MediaImporter(modelContainer: modelContainer)
			do {
				try await mediaImporter.updateMediaItem(identifier: identifier)
			} catch let importError as ImportError {
				MediaImporter.showImportError(importError)
			}
		}
	}

	func playWithAlternatePlayer() {
		if useInAppPlayer {
			mediaItem.playWithDefaultPlayer()
		} else {
			mediaItem.play(playType: .play, openWindow: openWindow)
		}
	}
}
