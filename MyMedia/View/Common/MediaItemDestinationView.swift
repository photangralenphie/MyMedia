//
// Copyright © 2026 MyMedia.
// Licensed under the MIT License.
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
