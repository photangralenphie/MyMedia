//
// Copyright © 2026 MyMedia.
// Licensed under the MIT License.
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
		if !mediaItemsFilteredByDescription.isEmpty {
			ForEach(mediaItemsFilteredByDescription, id: \.id) { mediaItem in
				let highlightedTokens = SearchVm.highlightResult(MetadataUtil.getDescription(mediaItem: mediaItem) ?? "", matching: searchVm.searchText)
				SearchForDescriptionCellView(mediaItem: mediaItem, highlightedTokens: highlightedTokens)
					.padding(.bottom, 6)
			}

			SearchShowAllButton(searchScope: .description, preview: preview, filteredResults: mediaItemsFilteredByDescription)
		} else {
			NoSearchResultsView(preview: preview)
		}
    }
}

#Preview {
	SearchView(mediaItems: DebugData.items)
}
