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
				ArtworkView(imageData: mediaItem.artwork, title: mediaItem.title, subtitle: "(\(String(mediaItem.year)))")
				
				Text("\(mediaItem.title) (\(String(mediaItem.year)))")
					.frame(maxWidth: LayoutConstants.artworkWidth, alignment: .leading)
				
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
