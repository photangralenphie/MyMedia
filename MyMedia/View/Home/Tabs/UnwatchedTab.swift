//
// Copyright © 2025 MyMedia.
// Licensed under the MIT License.
//

import SwiftUI

struct UnwatchedTab: TabContent {

	let tvShows: [TvShow]
	let movies: [Movie]

	@AppStorage("sortOrderUnwatched") private var sortOrderUnwatched = SortOption.title
	@AppStorage("viewPreferenceUnwatched") private var viewPreferenceUnwatched = ViewOption.grid
	@AppStorage("useSectionsUnwatched") private var useSectionsUnwatched = true

	private let tab = Tabs.unwatched

    var body: some TabContent<TabValue> {
		let unwatched: [any MediaItem] = tvShows.filter { !$0.isWatched } + movies.filter { !$0.isWatched }

		GenericTab(tab: tab) {
			LayoutSwitchingView(
				mediaItems: unwatched,
				sorting: $sortOrderUnwatched,
				viewPreference: $viewPreferenceUnwatched,
				useSections: $useSectionsUnwatched,
				navTitle: tab.title
			)
		}
    }
}
