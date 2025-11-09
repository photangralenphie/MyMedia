//
//  PinnedTabs.swift
//  MyMedia
//
//  Created by Jonas Helmer on 12.10.25.
//

import SwiftUI

struct PinnedTabs: TabContent {
	
	let tvShows: [TvShow]
	let movies: [Movie]
	let collections: [MediaCollection]
	
	@Environment(\.modelContext) private var modelContext
	
	var pinnedItems: [any IsPinnable] {
		(tvShows + movies + collections).filter({ $0.isPinned })
	}
	
    var body: some TabContent<TabValue> {
		if !pinnedItems.isEmpty {
			TabSection("Pinned") {
				ForEach(pinnedItems, id: \.id) { pinnedItem in
					let unpinButton = Button("Unpin", systemImage: "pin.slash") { unpinItem(pinnedItem) }

					if let collection = pinnedItem as? MediaCollection {
						Tab(collection.title, systemImage: collection.systemImageName, value: collection.id.uuidString) {
							LayoutSwitchingView(
								mediaItems: collection.mediaItems,
								sorting: Bindable(collection).sort,
								viewPreference: Bindable(collection).viewPreference,
								useSections: Bindable(collection).useSections,
								navTitle: LocalizedStringKey(collection.title)
							) {
								CollectionHeaderView(collection: collection)
							}
							.environment(\.mediaContext, .collection(collection))
							.id(collection.id.uuidString)
						}
						.dropDestination(for: String.self) { ids in dropMediaItemOnCollection(target: collection, ids: ids) }
						.contextMenu { unpinButton }
						.customizationID(pinnedItem.id.uuidString)
					} else {
						Tab(pinnedItem.title, systemImage: pinnedItem.systemImageName, value: pinnedItem.id.uuidString) {
							NavigationStack {
								switch pinnedItem {
									case let tvShow as TvShow:
										TvShowDetailView(tvShow: tvShow)
											.id(tvShow.id.uuidString)
									case let movie as Movie:
										MovieDetailView(movie: movie)
											.id(movie.id.uuidString)
									default:
										EmptyView()
								}
							}
						}
						.contextMenu { unpinButton }
						.customizationID(pinnedItem.id.uuidString)
					}
				}
			}
			.customizationID(Tabs.pinnedSection)
		}
    }
	
	func dropMediaItemOnCollection(target: MediaCollection, ids: [any Transferable]) {
		let allMediaItems: [any MediaItem] = tvShows + movies
		for id in ids {
			if let uuid = id as? String,
			   let itemToAdd = allMediaItems.first(where: { $0.id.uuidString == uuid }) {
				target.addMediaItem(itemToAdd)
			}
		}
	}
		
	func unpinItem(_ pinnedItem: any IsPinnable) {
		if var item = pinnedItems.filter({ $0.id == pinnedItem.id}).first {
			withAnimation {
				item.isPinned = false
				try? modelContext.save()
			}
		}
	}
}
