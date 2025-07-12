//
//  ListView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 17.06.25.
//

import SwiftUI
import OrderedCollections

struct ListView: View {
	
	let useSections: Bool
	let groupedMediaItems: OrderedDictionary<String, [any MediaItem]>
	let filteredMediaItems: [any MediaItem]
	
	var body: some View {
		LazyVStack(pinnedViews: [.sectionHeaders]) {
			if useSections {
				ForEach(Array(groupedMediaItems.keys), id: \.self) { section in
					Section {
						ForEach(groupedMediaItems[section] ?? [], id: \.id) { mediaItem in
							LayoutCellView(mediaItem: mediaItem, layout: .list)
								.listRowSeparator(.hidden)
						}
					} header: {
						LayoutSectionHeader(section: section)
					}
				}
			} else {
				ForEach(filteredMediaItems, id: \.id) { mediaItem in
					LayoutCellView(mediaItem: mediaItem, layout: .list)
				}
			}
			
		}
		.padding(.horizontal, LayoutConstants.gridSpacing)
	}
}
