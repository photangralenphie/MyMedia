//
//  TVGrid.swift
//  MyMedia
//
//  Created by Jonas Helmer on 31.03.25.
//

import SwiftUI

struct TVGrid: View {
	
	let tvShows: [TvShow]
	let layout = [GridItem(.adaptive(minimum: 300), spacing: 20, alignment: .top)]

	@State private var searchText: String = ""
	
	var filteredTvShows: [TvShow] {
		if searchText.isEmpty { return tvShows }
		
		return tvShows.filter {
			$0.title
				.lowercased()
				.contains(searchText.lowercased())
		}
	}
	
    var body: some View {
		NavigationStack {
			ScrollView {
				LazyVGrid(columns: layout) {
					ForEach(filteredTvShows) { tvShow in
						NavigationLink {
							TVDetail(tvShow: tvShow)
						} label: {
							TVCell(tvShow:	tvShow)
						}
						.buttonStyle(PlainButtonStyle())
						.padding(.bottom)
					}
				}
				.padding()
			}
			.searchable(text: $searchText, placement: .automatic, prompt: "Search")
			.navigationTitle("TV Shows")
		}
    }
}

//#Preview {
//    TVGrid()
//}
