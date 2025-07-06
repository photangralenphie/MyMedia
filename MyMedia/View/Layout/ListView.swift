//
//  ListView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 17.06.25.
//

import SwiftUI
import OrderedCollections

struct ListView: View {
	
	let groupedWatchables: OrderedDictionary<String, [any MediaItem]>
	
	var body: some View {
		LazyVStack(pinnedViews: [.sectionHeaders]) {
			ForEach(Array(groupedWatchables.keys), id: \.self) { section in
				Section {
					ForEach(groupedWatchables[section] ?? [], id: \.id) { mediaItem in
						LayoutCellView(mediaItem: mediaItem, layout: .list)
							.listRowSeparator(.hidden)
					}
				} header: {
					LayoutSectionHeader(section: section)
				}
			}
		}
		.padding(.horizontal, LayoutConstants.gridSpacing)
	}
}
