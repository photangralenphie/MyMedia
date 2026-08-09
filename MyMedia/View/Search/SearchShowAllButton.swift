//
//  SearchShowAllButton.swift
//  MyMedia
//
//  Created by Jonas Helmer on 11.04.26.
//

import SwiftUI

struct SearchShowAllButton<FilteredResult>: View {
	
	let searchScope: SearchScope
	let preview: Bool
	let filteredResults: [FilteredResult]
	
	@Environment(SearchVm.self) private var searchVm
	
    var body: some View {
		if preview && filteredResults.count >= LayoutConstants.numPreviewSearchResults {
			HStack {
				Spacer()
				Button("Show All") { withAnimation { searchVm.searchScope = searchScope } }
					.buttonStyle(.bordered)
					.buttonBorderShape(.capsule)
					.tint(.accentColor)
			}
		}
    }
}

#Preview {
	SearchShowAllButton(searchScope: .title, preview: true, filteredResults: DebugData.items)
}
