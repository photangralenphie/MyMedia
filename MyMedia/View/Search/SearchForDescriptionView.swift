//
//  SearchForDescriptionView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 19.02.26.
//

import SwiftUI

struct SearchForDescriptionView: View {
	
	init(preview: Bool = false) {
		self.preview = preview
	}
	
	let preview: Bool
	@Environment(SearchVm.self) private var searchVm
	
    var body: some View {
		let mediaItemsFilteredByDescription = preview ? Array(searchVm.mediaItemsFilteredByDescription.prefix(LayoutConstants.numPreviewSearchResults)) : searchVm.mediaItemsFilteredByDescription
		if mediaItemsFilteredByDescription.count > 0 {
			ForEach(mediaItemsFilteredByDescription, id: \.id) { mediaItem in
				let highlightedTokens = SearchVm.highlightResult(MetadataUtil.getDescription(mediaItem: mediaItem) ?? "", matching: searchVm.searchText)
				SearchForDescriptionCellView(mediaItem: mediaItem, highlightedTokens: highlightedTokens)
					.padding(.bottom, 6)
			}
			
			SearchShowAllButton(searchScope: .description, preview: preview, filteredMediaItems: mediaItemsFilteredByDescription)
		} else {
			NoSearchResultsView(preview: preview)
		}
    }
}



#Preview {
	SearchView(mediaItems: DebugData.items)
}
