//
// Copyright © 2025 MyMedia.
// Licensed under the MIT License.
//

import SwiftUI

struct TvShowsGenresTab: TabContent {

	let tvShows: [TvShow]

	@AppStorage(InterfaceStateKeys.sortOrder(Tabs.tvShowsGenres.rawValue)) private var sortOrder = SortOption.title
	@AppStorage(InterfaceStateKeys.viewPreference(Tabs.tvShowsGenres.rawValue)) private var viewPreference = ViewOption.grid
	@AppStorage(InterfaceStateKeys.useSections(Tabs.tvShowsGenres.rawValue)) private var useSections = true

	private let tab = Tabs.tvShowsGenres

    var body: some TabContent<TabValue> {
		GenericTab(tab: tab) {
			GenresView(
				mediaItems: tvShows,
				sortOrder: $sortOrder,
				viewPreference: $viewPreference,
				useSections: $useSections
			)
		}
    }
}
