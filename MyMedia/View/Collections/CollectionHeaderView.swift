//
//  CollectionHeaderView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 17.05.25.
//

import SwiftUI
import MarkdownUI

struct CollectionHeaderView: View {
	
	let collection: MediaCollection
	@Environment(CommandResource.self) private var commandResource
	@Environment(\.dismiss) private var dismiss
	
	@State private var showEditSheet: Bool = false
    var body: some View {
		HStack(alignment: .bottom) {
			ArtworkView(imageData: collection.artwork, title: collection.title, subtitle: "^[\(collection.mediaItems.count) Item](inflect: true)", scale: 1.3)
			
			VStack(alignment: .leading) {
				Text(LocalizedStringKey(collection.title))
					.font(.largeTitle)
					.bold()
				
				Text("^[\(collection.mediaItems.count) Item](inflect: true)")
					.textCase(.uppercase)
					.bold()
					.foregroundStyle(.secondary)
				
				if let description = collection.collectionDescription, !description.isEmpty {
					Markdown(description)
				}
			}
			.padding(.leading)
			
			Spacer()
		}
		.padding()
		.sheet(item: Bindable(commandResource).collectionEditVm) { vm in
			CollectionEditView(vm: vm )
		}
		.toolbar {
			if #available(macOS 26.0, *) {
				ToolbarSpacer(.fixed)
			}

			ToolbarItem {
				Menu("Actions", systemImage: "ellipsis.circle") {
					CollectionActionsView(collection: collection, applyShortcuts: true) {
						dismiss()
					}
				}
			}
		}
    }
}
