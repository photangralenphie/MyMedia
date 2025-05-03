//
//  GridCellView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 31.03.25.
//

import SwiftUI

struct GridCellView: View {
	
	let watchable: any MediaItem
	
    var body: some View {
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
			VStack(alignment: .leading) {
				ArtworkView(watchable: watchable )
				
				Text(watchable.title) + Text(" (\(String(watchable.year)))")
				
				if let tvShow = watchable as? TvShow {
					Text("^[\(Set(tvShow.episodes.compactMap(\.season)).count) SEASON](inflect: true) - ^[\(tvShow.episodes.count) EPISODE](inflect: true) ")
						.font(.caption)
						.foregroundStyle(.secondary)
				}
			}
			.contextMenu {
				WatchableActionsView(watchable: watchable) { }
			}
		}
		.buttonStyle(PlainButtonStyle())
		.padding(.bottom)
    }
}
