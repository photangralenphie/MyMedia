//
// Copyright © 2025 MyMedia.
// Licensed under the MIT License.
//

import SwiftUI

struct TvShowsGenresTab: TabContent {

	let tvShows: [TvShow]

	@AppStorage("sortOrderTvShowsGenre") private var sortOrderTvShowsGenre = SortOption.title
	@AppStorage("viewPreferenceTvShowsGenre") private var viewPreferenceTvShowsGenre = ViewOption.grid
	@AppStorage("useSectionsTvShowsGenre") private var useSectionsTvShowsGenre = true

	private let tab = Tabs.tvShowsGenres

    var body: some TabContent<TabValue> {
		GenericTab(tab: tab) {
			GenresView(
				mediaItems: tvShows,
				sortOrder: $sortOrderTvShowsGenre,
				viewPreference: $viewPreferenceTvShowsGenre,
				useSections: $useSectionsTvShowsGenre
			)
		}
    }
}
