//
//  TvShowsMiniSeriesTab.swift
//  MyMedia
//
//  Created by Jonas Helmer on 09.11.25.
//

import SwiftUI

struct TvShowsGenresTab: TabContent {
	
	let tvShows: [TvShow]
	
	@AppStorage(PreferenceKeys.useMiniSeries) private var useMiniSeries: Bool = true
	
	@AppStorage("sortOrderTvShowsMiniSeries") private var sortOrderTvShowsMiniSeries = SortOption.title
	@AppStorage("viewPreferenceTvShowsMiniSeries") private var viewPreferenceTvShowsMiniSeries = ViewOption.grid
	@AppStorage("useSectionsTvShowsMiniSeries") private var useSectionsTvShowsMiniSeries = true
	
	private let tab = Tabs.tvShowsMiniSeries
	
	var body: some TabContent<TabValue> {
		GenericTab(tab: tab) {
			LayoutSwitchingView(
				mediaItems: tvShows.filter({ $0.isMiniSeries }),
				sorting: $sortOrderTvShowsMiniSeries,
				viewPreference: $viewPreferenceTvShowsMiniSeries,
				useSections: $useSectionsTvShowsMiniSeries,
				navTitle: tab.title
			)
		}
		.contextMenu {
			Button("Hide", systemImage: "eye.slash") {
				useMiniSeries = false
			}
		}
	}
}
