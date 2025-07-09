//
//  LayoutCellView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 31.03.25.
//

import SwiftUI

struct LayoutCellView: View {
	
	let mediaItem: any MediaItem
	let layout: ViewOption
	
	@ViewBuilder
	var contentView: some View {
		switch layout {
			case .grid:
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
			case .list:
				HStack {
					ArtworkView(imageData: mediaItem.artwork, title: mediaItem.title, subtitle: "(\(String(mediaItem.year)))", scale: 0.6)
					
					VStack(alignment: .leading) {
						
						Text(mediaItem.title)
							.font(.title2)
							.bold()
							.padding(.bottom, 1)
						
						Text("(\(String(mediaItem.year)))")
							.font(.title3)
							.padding(.bottom, 2)
						
						if let tvShow = mediaItem as? TvShow {
							Text("^[\(Set(tvShow.episodes.compactMap(\.season)).count) Season](inflect: true) - ^[\(tvShow.episodes.count) Episode](inflect: true) ")
								.textCase(.uppercase)
								.foregroundStyle(.secondary)
						}
						
					}
					Spacer()
				}
			case .detailList:
				Image(systemName: "chevron.right.circle")
		}
	}
	
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
			contentView
				.contextMenu {
					MediaItemActionsView(mediaItem: mediaItem, applyShortcuts: false) { }
				}
				.mediaItemDraggable(mediaItem: mediaItem)
		}
		.buttonStyle(PlainButtonStyle()) // IDKW but .plain isn't working
		.padding(.bottom)
    }
}
