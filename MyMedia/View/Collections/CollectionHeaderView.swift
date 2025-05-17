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
	 
    var body: some View {
		HStack(alignment: .bottom) {
			ArtworkView(imageData: collection.artwork, title: collection.title, subtitle: "^[\(collection.mediaItems.count) Item](inflect: true)", scale: 1.3)
			
			VStack(alignment: .leading) {
				Text(LocalizedStringKey(collection.title))
					.font(.largeTitle)
					.bold()
				
					Text("^[\(collection.mediaItems.count) ITEM](inflect: true)")
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
    }
}
