//
//  CollectionCellView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 11.05.25.
//

import SwiftUI

struct CollectionCellView: View {
	
	let collection: MediaCollection
	@State private var showEditSheet: Bool = false
	
    var body: some View {
		NavigationLink {
			LayoutSwitchingView(
				mediaItems: collection.mediaItems,
				sorting: Bindable(collection).sort,
				viewPreference: Bindable(collection).viewPreference,
				useSections: Bindable(collection).useSections,
				navTitle: LocalizedStringKey(collection.title))
			{
				CollectionHeaderView(collection: collection)
			}
			.environment(\.mediaContext, .collection(collection))
		} label: {
			VStack(alignment: .leading) {
				ArtworkView(imageData: collection.artwork, title: collection.title, subtitle: "^[\(collection.mediaItems.count) Item](inflect: true)")
				
				Text(collection.title)
				
				Text("^[\(collection.mediaItems.count) Item](inflect: true)")
					.textCase(.uppercase)
					.font(.caption)
					.foregroundStyle(.secondary)
			}
			.contextMenu {
				CollectionActionsView(collection: collection, applyShortcuts: false) { }
			}
		}
		.buttonStyle(.plain)
		.padding(.bottom)
    }
}
