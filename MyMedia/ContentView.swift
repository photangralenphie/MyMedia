//
//  ContentView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 27.03.25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
	
	public let tvShows: [TvShow]
	@State private var metadata: String = ""
	@State private var selectedTvShow: TvShow?
	
    var body: some View {
        NavigationStack {
			List(selection: $selectedTvShow) {
                ForEach(tvShows) { tvShow in
					Button {
						selectedTvShow = tvShow
					} label: {
						Text(tvShow.title) + Text(" (\(tvShow.year))")
					}
                }
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
        }
    }
}

#Preview {
    Home()
		.modelContainer(for: TvShow.self, inMemory: true)
}
