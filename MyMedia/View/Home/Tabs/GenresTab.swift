//
// Copyright © 2025 MyMedia.
// Licensed under the MIT License.
//

import SwiftUI

struct GenresTab: TabContent {

	let tvShows: [TvShow]
	let movies: [Movie]

	@AppStorage(InterfaceStateKeys.sortOrder(Tabs.genres.rawValue)) private var sortOrder = SortOption.title
	@AppStorage(InterfaceStateKeys.viewPreference(Tabs.genres.rawValue)) private var viewPreference = ViewOption.grid
	@AppStorage(InterfaceStateKeys.useSections(Tabs.genres.rawValue)) private var useSections = true

	private let tab = Tabs.genres

    var body: some TabContent<TabValue> {
		GenericTab(tab: tab) {
			GenresView(
				mediaItems: tvShows + movies,
				sortOrder: $sortOrder,
				viewPreference: $viewPreference,
				useSections: $useSections
			)
		}
    }
}
