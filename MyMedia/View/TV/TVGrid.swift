//
//  TVGrid.swift
//  MyMedia
//
//  Created by Jonas Helmer on 31.03.25.
//

import SwiftUI

struct TVGrid: View {
	
	let tvShows: [TvShow]
	let layout = Array(repeating: GridItem(.flexible(minimum: 200, maximum: 300)), count: 3)
	
    var body: some View {
		NavigationStack {
			ScrollView {
				LazyVGrid(columns: layout) {
					ForEach(tvShows) { tvShow in
						NavigationLink {
							TVDetail(tvShow: tvShow)
						} label: {
							TVCell(tvShow:	tvShow)
						}
					}
				}
			}
			.navigationTitle("TV Shows")
		}
    }
}

//#Preview {
//    TVGrid()
//}
