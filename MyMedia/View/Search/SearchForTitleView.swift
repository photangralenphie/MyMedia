//
//  SearchForTitleView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 19.02.26.
//

import SwiftUI

struct SearchForTitleView: View {
	
	init(preview: Bool = false) {
		self.preview = preview
	}
	let preview: Bool
	@Environment(SearchVm.self) private var searchVm
	
    var body: some View {
		let mediaItemsFilteredByTitle = preview ? Array(searchVm.mediaItemsFilteredByTitle.prefix(5)) : searchVm.mediaItemsFilteredByTitle
		if mediaItemsFilteredByTitle.count > 0 {
			ForEach(mediaItemsFilteredByTitle, id: \.id) { mediaItem in
				NavigationLink {
					MediaItemDestinationView(mediaItem: mediaItem)
				} label: {
					HStack {
						ArtworkView(imageData: mediaItem.artwork, title: mediaItem.title, subtitle: "(\(String(mediaItem.year)))", scale: 0.3)
						let highlightedTokens = SearchVm.highlightResult(mediaItem.title, matching: searchVm.searchText)
						VStack(alignment: .leading) {
							Text(highlightedTokens)
							
							if let subtitle = getSubtitle(for: mediaItem) {
								Text(subtitle)
									.font(.footnote)
									.foregroundStyle(.secondary)
							}
						}
					}
				}
			}
			if preview && mediaItemsFilteredByTitle.count > 4 {
				HStack {
					Spacer()
					Button("Show All") { withAnimation { searchVm.searchScope = .title } }
						.buttonStyle(.bordered)
						.buttonBorderShape(.capsule)
						.tint(.accentColor)
				}
			}
		} else {
			NoSearchResultsView(preview: preview)
		}
    }
	
	func getSubtitle(for mediaItem: any MediaItem) -> String? {
		switch mediaItem {
			case let movie as Movie:
				movie.releaseDate.formatted(date: .abbreviated, time: .omitted)
			case let tvShow as TvShow:
				String(localized: "\(String(tvShow.episodes.count)) Episodes")
			case let episode as Episode:
				String(localized: "Season \(String(episode.season)), Episode \(String(episode.episode)) from \(episode.tvShow.title)")
			default: nil
		}
	}
}

#Preview {
	NavigationStack {
		SearchView(mediaItems: DebugData.items)
	}
	.frame(width: 800, height: 800)
}
