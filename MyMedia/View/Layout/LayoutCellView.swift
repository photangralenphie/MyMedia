//
//  LayoutCellView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 31.03.25.
//

import SwiftUI

struct LayoutCellView: View {

	let mediaItem: (any MediaItem)?
	let collection: MediaCollection?

	let layout: ViewOption

	let title: String
	let subtitle: String?

	let artwork: Data?
	let artworkSubtitle: String

	init(mediaItem: any MediaItem, layout: ViewOption) {
		self.mediaItem = mediaItem
		self.collection = nil

		self.artwork = mediaItem.artwork
		self.title = mediaItem.title
		if let tvShow = mediaItem as? TvShow {
			self.subtitle = String(localized: "\(Set(tvShow.episodes.compactMap(\.season)).count) Season - \(tvShow.episodes.count) Episode")
		} else {
			self.subtitle = nil
		}
		self.artworkSubtitle = "(\(String(mediaItem.year)))"
		self.layout = layout
	}

	init(collection: MediaCollection, layout: ViewOption) {
		self.collection = collection
		self.mediaItem = nil

		self.artwork = collection.artwork
		self.artworkSubtitle = String(localized: "\(collection.mediaItems.count) Item")
		self.title = collection.title
		self.subtitle = String(localized: "\(collection.mediaItems.count) Item")
		self.layout = layout
	}

	@ViewBuilder
	var contentView: some View {
		switch layout {
			case .grid:
				GridCellView(artwork: artwork, artworkSubtitle: artworkSubtitle, title: title, subtitle: artworkSubtitle)
			case .list:
				ListCellView(artwork: artwork, artworkSubtitle: artworkSubtitle, title: title, subtitle: artworkSubtitle)
			case .detailList:
				Image(systemName: "chevron.right.circle")
		}
	}

    var body: some View {
		NavigationLink {
			if let mediaItem {
				MediaItemDestinationView(mediaItem: mediaItem)
			}
			if let collection {
				LayoutSwitchingView(
					mediaItems: collection.mediaItems,
					sorting: Bindable(collection).sort,
					viewPreference: Bindable(collection).viewPreference,
					useSections: Bindable(collection).useSections,
					navTitle: LocalizedStringKey(collection.title)) {
					CollectionHeaderView(collection: collection)
				}
				.environment(\.mediaContext, .collection(collection))
			}
		} label: {
			let contentViewWithContextMenu = contentView
				.contextMenu {
					if let mediaItem {
						MediaItemActionsView(mediaItem: mediaItem, applyShortcuts: false) { }
					}
					if let collection {
						CollectionActionsView(collection: collection, applyShortcuts: false) { }
					}
				}

			if let mediaItem {
				contentViewWithContextMenu
					.mediaItemDraggable(mediaItem: mediaItem)
			} else {
				contentViewWithContextMenu
			}
		}
		.buttonStyle(PlainButtonStyle()) // IDKW but .plain isn't working
		.padding(.bottom)
    }
}
