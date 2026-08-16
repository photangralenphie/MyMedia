//
// Copyright © 2025 MyMedia.
// Licensed under the MIT License.
//

import SwiftUI

struct MoviesTab: TabContent {

	let movies: [Movie]

	@AppStorage("sortOrderMovies") private var sortOrderMovies = SortOption.title
	@AppStorage("viewPreferenceMovies") private var viewPreferenceMovies = ViewOption.grid
	@AppStorage("useSectionsMovies") private var useSectionsMovies = true

	private let tab = Tabs.movies

    var body: some TabContent<TabValue> {
		GenericTab(tab: tab) {
			LayoutSwitchingView(
				mediaItems: movies,
				sorting: $sortOrderMovies,
				viewPreference: $viewPreferenceMovies,
				useSections: $useSectionsMovies,
				navTitle: "Movies"
			)
		}
    }
}
