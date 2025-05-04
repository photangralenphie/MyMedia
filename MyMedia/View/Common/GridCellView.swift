//
//  GridCellView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 31.03.25.
//

import SwiftUI

struct GridCellView: View {
	
	let mediaItem: any MediaItem
	
    var body: some View {
		NavigationLink {
			switch mediaItem {
				case let tvShow as TvShow:
					TvShowDetailView(tvShow: tvShow)
				case let movie as Movie:
					MovieDetailView(movie: movie)
				default:
					Text("Episodes are not supported in Grid view")
			}
		} label: {
			VStack(alignment: .leading) {
				ArtworkView(mediaItem: mediaItem )
				
				Text(mediaItem.title) + Text(" (\(String(mediaItem.year)))")
				
				if let tvShow = mediaItem as? TvShow {
					Text("^[\(Set(tvShow.episodes.compactMap(\.season)).count) SEASON](inflect: true) - ^[\(tvShow.episodes.count) EPISODE](inflect: true) ")
						.font(.caption)
						.foregroundStyle(.secondary)
				}
			}
			.contextMenu {
				MediaItemActionsView(mediaItem: mediaItem) { }
			}
		}
		.buttonStyle(PlainButtonStyle())
		.padding(.bottom)
    }
}
