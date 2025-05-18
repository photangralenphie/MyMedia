//
//  CollectionCellView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 11.05.25.
//

import SwiftUI

struct CollectionCellView: View {
	
	let collection: MediaCollection
	@State private var collectionSorting: SortOption = .title
	
    var body: some View {
		NavigationLink {
			GridView(mediaItems: collection.mediaItems, sorting: $collectionSorting, navTitle: LocalizedStringKey(collection.title)) {
				CollectionHeaderView(collection: collection)
			}
		} label: {
			VStack(alignment: .leading) {
				ArtworkView(imageData: collection.artwork, title: collection.title, subtitle: "^[\(collection.mediaItems.count) Item](inflect: true)")
				
				Text(LocalizedStringKey(collection.title))
				
				Text("^[\(collection.mediaItems.count) ITEM](inflect: true)")
					.font(.caption)
					.foregroundStyle(.secondary)
			}
			.contextMenu {
				CollectionActionsView(collection: collection) { }
			}
		}
		.buttonStyle(.plain)
		.padding(.bottom)
    }
}
