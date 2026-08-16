//
// Copyright © 2025 MyMedia.
// Licensed under the MIT License.
//

import SwiftUI

struct TvShowsTab: TabContent {

	let tvShows: [TvShow]

	@AppStorage("sortOrderTvShows") private var sortOrderTvShows = SortOption.title
	@AppStorage("viewPreferenceTvShows") private var viewPreferenceTvShows = ViewOption.grid
	@AppStorage("useSectionsTvShows") private var useSectionsTvShows = true

	private let tab = Tabs.tvShows

    var body: some TabContent<TabValue> {
		GenericTab(tab: tab) {
			LayoutSwitchingView(
				mediaItems: tvShows,
				sorting: $sortOrderTvShows,
				viewPreference: $viewPreferenceTvShows,
				useSections: $useSectionsTvShows,
				navTitle: "TV Shows"
			)
		}
    }
}
