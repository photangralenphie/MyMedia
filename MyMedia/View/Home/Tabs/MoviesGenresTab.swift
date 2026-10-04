//
// Copyright © 2025 MyMedia.
// Licensed under the MIT License.
//

import SwiftUI

struct MoviesGenresTab: TabContent {

	let movies: [Movie]

	@AppStorage(InterfaceStateKeys.sortOrder(Tabs.moviesGenres.rawValue)) private var sortOrder = SortOption.title
	@AppStorage(InterfaceStateKeys.viewPreference(Tabs.moviesGenres.rawValue)) private var viewPreference = ViewOption.grid
	@AppStorage(InterfaceStateKeys.useSections(Tabs.moviesGenres.rawValue)) private var useSections = true

	private let tab = Tabs.moviesGenres

    var body: some TabContent<TabValue> {
		GenericTab(tab: tab) {
			GenresView(
				mediaItems: movies,
				sortOrder: $sortOrder,
				viewPreference: $viewPreference,
				useSections: $useSections
			)
		}
    }
}
