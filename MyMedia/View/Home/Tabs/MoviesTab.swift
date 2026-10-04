//
// Copyright © 2025 MyMedia.
// Licensed under the MIT License.
//

import SwiftUI

struct MoviesTab: TabContent {

	let movies: [Movie]

	@AppStorage(InterfaceStateKeys.sortOrder(Tabs.movies.rawValue)) private var sortOrder = SortOption.title
	@AppStorage(InterfaceStateKeys.viewPreference(Tabs.movies.rawValue)) private var viewPreference = ViewOption.grid
	@AppStorage(InterfaceStateKeys.useSections(Tabs.movies.rawValue)) private var useSections = true

	private let tab = Tabs.movies

    var body: some TabContent<TabValue> {
		GenericTab(tab: tab) {
			LayoutSwitchingView(
				mediaItems: movies,
				sorting: $sortOrder,
				viewPreference: $viewPreference,
				useSections: $useSections,
				navTitle: "Movies"
			)
		}
    }
}
