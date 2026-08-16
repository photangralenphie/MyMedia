//
// Copyright © 2026 MyMedia.
// Licensed under the MIT License.
//

import SwiftUI

struct SearchResultSubtitle: View {

	let mediaItem: any MediaItem

    var body: some View {
		if let subtitle = getSubtitle(for: mediaItem) {
			Text(subtitle)
				.font(.footnote)
				.foregroundStyle(.secondary)
		}
    }

	func getSubtitle(for mediaItem: any MediaItem) -> String? {
		switch mediaItem {
			case let movie as Movie:
				movie.releaseDate.formatted(date: .abbreviated, time: .omitted)
			case let tvShow as TvShow:
				String(localized: "\(tvShow.episodes.count) Episode")
			case let episode as Episode:
				String(localized: "Season \(episode.season), Episode \(episode.episode) from \(episode.tvShow.title)")
			default: nil
		}
	}
}

#Preview {
	SearchResultSubtitle(mediaItem: DebugData.items.first!)
}
