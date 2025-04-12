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
						NavigationLink {
							switch watchable {
								case let tvShow as TvShow:
									TvShowDetailView(tvShow: tvShow)
								case let movie as Movie:
									MovieDetailView(movie: movie)
								default:
									Text("Episodes are not supported in Grid view")
							}
						} label: {
							GridCellView(watchable: watchable)
						}
						.buttonStyle(PlainButtonStyle())
						.padding(.bottom)
					}
				}
				.padding()
			}
			.searchable(text: $searchText, placement: .automatic, prompt: "Search")
			.navigationTitle(navTitle)
		}
    }
}
