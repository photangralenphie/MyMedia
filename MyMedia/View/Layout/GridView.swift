//
//  GridView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 17.06.25.
//

import SwiftUI
import OrderedCollections

struct GridView: View {
	
	let useSections: Bool
	let groupedMediaItems: OrderedDictionary<String, [any MediaItem]>
	let filteredMediaItems: [any MediaItem]
	
	private let layout = [GridItem(.adaptive(minimum: LayoutConstants.artworkWidth), spacing: LayoutConstants.gridSpacing, alignment: .top)]
	
    var body: some View {
		LazyVGrid(columns: layout, pinnedViews: [.sectionHeaders]) {
			if useSections {
				ForEach(Array(groupedMediaItems.keys), id: \.self) { section in
					Section {
						ForEach(groupedMediaItems[section] ?? [], id: \.id) { mediaItem in
							LayoutCellView(mediaItem: mediaItem, layout: .grid)
						}
						
					} header: {
						LayoutSectionHeader(section: section)
					}
				}
			} else {
				ForEach(filteredMediaItems, id: \.id) { mediaItem in
					LayoutCellView(mediaItem: mediaItem, layout: .grid)
				}
			}
		}
		.padding(.horizontal, LayoutConstants.gridSpacing)
    }
}
