//
// Copyright © 2025 MyMedia.
// Licensed under the MIT License.
//

import SwiftUI

struct TvShowsMiniSeriesTab: TabContent {

	let tvShows: [TvShow]

	@AppStorage(PreferenceKeys.useMiniSeries) private var useMiniSeries: Bool = true

	@AppStorage(InterfaceStateKeys.sortOrder(Tabs.tvShowsMiniSeries.rawValue)) private var sortOrder = SortOption.title
	@AppStorage(InterfaceStateKeys.viewPreference(Tabs.tvShowsMiniSeries.rawValue)) private var viewPreference = ViewOption.grid
	@AppStorage(InterfaceStateKeys.useSections(Tabs.tvShowsMiniSeries.rawValue)) private var useSections = true

	private let tab = Tabs.tvShowsMiniSeries

	var body: some TabContent<TabValue> {
		GenericTab(tab: tab) {
			LayoutSwitchingView(
				mediaItems: tvShows.filter(\.isMiniSeries),
				sorting: $sortOrder,
				viewPreference: $viewPreference,
				useSections: $useSections,
				navTitle: tab.title
			)
		}
		.contextMenu {
			Button("Hide", systemImage: "eye.slash") {
				withAnimation { useMiniSeries = false }
			}
			.labelStyle(.titleAndIcon)
		}
	}
}
