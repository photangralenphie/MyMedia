//
//  MediaItemDestinationView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 19.02.26.
//

import SwiftUI

struct MediaItemDestinationView: View {

	let mediaItem: any MediaItem

    var body: some View {
		switch mediaItem {
			case let tvShow as TvShow:
				TvShowDetailView(tvShow: tvShow)
			case let movie as Movie:
				MovieDetailView(movie: movie)
			case let episode as Episode:
				EpisodeDetailView(episode: episode)
			default:
				Text("Something went wrong")
		}
    }
}
