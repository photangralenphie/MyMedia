//
//  GridCellView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 31.03.25.
//

import SwiftUI

struct GridCellView: View {
	
	let mediaItem: any MediaItem
	private let scale = 0.4
	
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
					Text("^[\(Set(tvShow.episodes.compactMap(\.season)).count) Season](inflect: true) - ^[\(tvShow.episodes.count) Episode](inflect: true) ")
						.textCase(.uppercase)
						.font(.caption)
						.foregroundStyle(.secondary)
				}
			}
			.contextMenu {
				MediaItemActionsView(mediaItem: mediaItem, applyShortcuts: false) { }
			}
			.draggable(mediaItem.id.uuidString) {
				VStack {
					VStack(alignment: .leading) {
						ArtworkView(imageData: mediaItem.artwork, title: mediaItem.title, subtitle: "", scale: scale)
						Text("\(mediaItem.title) - (\(String(mediaItem.year)))")
					}
					.padding(5)
					.background(Material.regular)
					.clipShape(.rect(cornerRadius: LayoutConstants.cornerRadius * scale))
				}
			}
		}
		.buttonStyle(PlainButtonStyle())
		.padding(.bottom)
    }
}
