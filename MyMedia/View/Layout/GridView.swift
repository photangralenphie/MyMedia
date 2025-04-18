//
//  GridView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 31.03.25.
//

import SwiftUI

struct GridView: View {
	
	let watchable: [any Watchable]
	let layout = [GridItem(.adaptive(minimum: 300), spacing: 20, alignment: .top)]
	let navTitle: LocalizedStringKey

	@State private var searchText: String = ""
	
	var filteredWatchables: [any Watchable] {
		if searchText.isEmpty { return watchable }
		
		return watchable.filter {
			$0.title
				.lowercased()
				.contains(searchText.lowercased())
		}
	}
	
    var body: some View {
		NavigationStack {
			ScrollView {
				LazyVGrid(columns: layout) {
					ForEach(filteredWatchables, id: \.id) { watchable in
						GridCellView(watchable: watchable)
					}
				}
				.padding()
			}
			.searchable(text: $searchText, placement: .automatic, prompt: "Search")
			.navigationTitle(navTitle)
		}
    }
}
