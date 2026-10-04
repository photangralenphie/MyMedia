//
// Copyright © 2025 MyMedia.
// Licensed under the MIT License.
//

import SwiftUI

struct TvShowsTab: TabContent {

	let tvShows: [TvShow]

	@AppStorage(InterfaceStateKeys.sortOrder(Tabs.tvShows.rawValue)) private var sortOrder = SortOption.title
	@AppStorage(InterfaceStateKeys.viewPreference(Tabs.tvShows.rawValue)) private var viewPreference = ViewOption.grid
	@AppStorage(InterfaceStateKeys.useSections(Tabs.tvShows.rawValue)) private var useSections = true

	private let tab = Tabs.tvShows

    var body: some TabContent<TabValue> {
		GenericTab(tab: tab) {
			LayoutSwitchingView(
				mediaItems: tvShows,
				sorting: $sortOrder,
				viewPreference: $viewPreference,
				useSections: $useSections,
				navTitle: "TV Shows"
			)
		}
    }
}
