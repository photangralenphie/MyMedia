//
// Copyright © 2025 MyMedia.
// Licensed under the MIT License.
//

import SwiftUI

struct FavoritesTab: TabContent {

	let tvShows: [TvShow]
	let movies: [Movie]

	@AppStorage(InterfaceStateKeys.sortOrder(Tabs.favorites.rawValue)) private var sortOrder = SortOption.title
	@AppStorage(InterfaceStateKeys.viewPreference(Tabs.favorites.rawValue)) private var viewPreference = ViewOption.grid
	@AppStorage(InterfaceStateKeys.useSections(Tabs.favorites.rawValue)) private var useSections = true

	private let tab = Tabs.favorites

    var body: some TabContent<TabValue> {
		let favourites: [any MediaItem] = tvShows.filter(\.isFavorite) + movies.filter(\.isFavorite)
		GenericTab(tab: tab) {
			LayoutSwitchingView(
				mediaItems: favourites,
				sorting: $sortOrder,
				viewPreference: $viewPreference,
				useSections: $useSections,
				navTitle: tab.title
			)
		}
    }
}
