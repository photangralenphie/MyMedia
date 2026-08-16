//
// Copyright © 2026 MyMedia.
// Licensed under the MIT License.
//

import SwiftUI

struct SearchForTitleView: View {

	init(preview: Bool = false) {
		self.preview = preview
	}

	let preview: Bool
	@Environment(SearchVm.self) private var searchVm

    var body: some View {
		let mediaItemsFilteredByTitle = preview ? Array(searchVm.mediaItemsFilteredByTitle.prefix(LayoutConstants.numPreviewSearchResults)) : searchVm.mediaItemsFilteredByTitle
		if !mediaItemsFilteredByTitle.isEmpty {
			ForEach(mediaItemsFilteredByTitle, id: \.id) { mediaItem in
				NavigationLink {
					MediaItemDestinationView(mediaItem: mediaItem)
				} label: {
					HStack(alignment: .top) {
						ArtworkView(imageData: mediaItem.artwork, title: mediaItem.title, subtitle: "(\(String(mediaItem.year)))", scale: 0.3)

						VStack(alignment: .leading) {
							let highlightedTokens = SearchVm.highlightResult(mediaItem.title, matching: searchVm.searchText)
							Text(highlightedTokens)
								.bold()

							SearchResultSubtitle(mediaItem: mediaItem)
						}
					}
				}
			}

			SearchShowAllButton(searchScope: .title, preview: preview, filteredResults: mediaItemsFilteredByTitle)
		} else {
			NoSearchResultsView(preview: preview)
		}
    }
}

#Preview {
	NavigationStack {
		SearchView(mediaItems: DebugData.items)
	}
	.frame(width: 800, height: 800)
}
