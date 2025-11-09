//
//  GenresTab.swift
//  MyMedia
//
//  Created by Jonas Helmer on 12.10.25.
//

import SwiftUI

struct GenresTab: TabContent {
	
	let tvShows: [TvShow]
	let movies: [Movie]
	
	@AppStorage("sortOrderGenres") private var sortOrderGenres = SortOption.title
	@AppStorage("viewPreferenceGenres") private var viewPreferenceGenres = ViewOption.grid
	@AppStorage("useSectionsGenres") private var useSectionsGenres = true
	
	private let tab = Tabs.genres
	
    var body: some TabContent<TabValue> {
		GenericTab(tab: tab) {
			GenresView(
				mediaItems: tvShows + movies,
				sortOrder: $sortOrderGenres,
				viewPreference: $viewPreferenceGenres,
				useSections: $useSectionsGenres
			)
		}
    }
}
