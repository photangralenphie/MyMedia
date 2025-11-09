//
//  FavoritesTab.swift
//  MyMedia
//
//  Created by Jonas Helmer on 12.10.25.
//

import SwiftUI

struct FavoritesTab: TabContent {
	
	let tvShows: [TvShow]
	let movies: [Movie]
	
	@AppStorage("sortOrderFavorites") private var sortOrderFavorites = SortOption.title
	@AppStorage("viewPreferenceFavorites") private var viewPreferenceFavorites = ViewOption.grid
	@AppStorage("useSectionsFavorites") private var useSectionsFavorites = true
	
	private let tab = Tabs.favorites
	
    var body: some TabContent<TabValue> {
		let favourites: [any MediaItem] = tvShows.filter({ $0.isFavorite }) + movies.filter({ $0.isFavorite })
		GenericTab(tab: tab) {
			LayoutSwitchingView(
				mediaItems: favourites,
				sorting: $sortOrderFavorites,
				viewPreference: $viewPreferenceFavorites,
				useSections: $useSectionsFavorites,
				navTitle: tab.title
			)
		}
    }
}
