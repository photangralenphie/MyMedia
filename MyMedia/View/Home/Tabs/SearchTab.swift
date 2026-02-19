//
//  SearchTab.swift
//  MyMedia
//
//  Created by Jonas Helmer on 12.10.25.
//

import SwiftUI

struct SearchTab: TabContent {
	
	let tvShows: [TvShow]
	let movies: [Movie]
	let episodes: [Episode]
	
	let tab = Tabs.search
	
    var body: some TabContent<TabValue> {
		GenericTab(tab: tab) {
			SearchView(mediaItems: tvShows + movies + episodes)
		}
    }
}
