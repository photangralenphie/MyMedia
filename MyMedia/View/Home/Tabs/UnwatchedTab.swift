//
// Copyright © 2025 MyMedia.
// Licensed under the MIT License.
//

import SwiftUI

struct UnwatchedTab: TabContent {

	let tvShows: [TvShow]
	let movies: [Movie]

	@AppStorage(InterfaceStateKeys.sortOrder(Tabs.unwatched.rawValue)) private var sortOrder = SortOption.title
	@AppStorage(InterfaceStateKeys.viewPreference(Tabs.unwatched.rawValue)) private var viewPreference = ViewOption.grid
	@AppStorage(InterfaceStateKeys.useSections(Tabs.unwatched.rawValue)) private var useSections = true

	private let tab = Tabs.unwatched

    var body: some TabContent<TabValue> {
		let unwatched: [any MediaItem] = tvShows.filter { !$0.isWatched } + movies.filter { !$0.isWatched }

		GenericTab(tab: tab) {
			LayoutSwitchingView(
				mediaItems: unwatched,
				sorting: $sortOrder,
				viewPreference: $viewPreference,
				useSections: $useSections,
				navTitle: tab.title
			)
		}
    }
}
