//
// Copyright © 2025 MyMedia.
// Licensed under the MIT License.
//

import SwiftUI

struct MoviesGenresTab: TabContent {

	let movies: [Movie]

	@AppStorage("sortOrderMoviesGenre") private var sortOrderMoviesGenre = SortOption.title
	@AppStorage("viewPreferenceMoviesGenre") private var viewPreferenceMoviesGenre = ViewOption.grid
	@AppStorage("useSectionsMoviesGenre") private var useSectionsMoviesGenre = true

	private let tab = Tabs.moviesGenres

    var body: some TabContent<TabValue> {
		GenericTab(tab: tab) {
			GenresView(
				mediaItems: movies,
				sortOrder: $sortOrderMoviesGenre,
				viewPreference: $viewPreferenceMoviesGenre,
				useSections: $useSectionsMoviesGenre
			)
		}
    }
}
