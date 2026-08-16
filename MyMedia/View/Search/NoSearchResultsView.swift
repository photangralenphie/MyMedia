//
// Copyright © 2026 MyMedia.
// Licensed under the MIT License.
//

import SwiftUI

struct NoSearchResultsView: View {

	let preview: Bool
	@Environment(SearchVm.self) private var searchVm

    var body: some View {
		if preview {
			Label("No Result", systemImage: "exclamationmark.magnifyingglass")
				.foregroundStyle(.secondary)
		} else {
			ContentUnavailableView.search(text: "No items with title \(searchVm.searchText) found")
		}
    }
}

#Preview {
	VStack {
		NoSearchResultsView(preview: true)
		Divider()
		NoSearchResultsView(preview: false)
	}
	.environment(SearchVm(mediaItems: []))
}
