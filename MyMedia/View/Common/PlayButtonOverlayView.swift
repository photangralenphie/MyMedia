//
//  PlayButtonOverlayView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 23.08.25.
//

import SwiftUI

struct PlayButtonOverlayView: View {
	
	public let mediaItem: any MediaItem
	
	public let width: CGFloat
	public let height: CGFloat
	public let cornerRadius: CGFloat
	
	@State private var showPlayButton: Bool = false
	
	public var progressWidth: CGFloat {
		var progress: CGFloat = 0
		switch mediaItem {
			case let tvShow as TvShow:
				let watched = tvShow.episodes.filter({ $0.isWatched })
				let numEpisodes = tvShow.episodes.count
				progress = CGFloat(watched.count) / CGFloat(numEpisodes)
			case let movie as Movie:
				progress = CGFloat(movie.progressMinutes) / CGFloat(movie.durationMinutes)
			case let episode as Episode:
				progress = CGFloat(episode.progressMinutes) / CGFloat(episode.durationMinutes)
			default: break;
		}
		
		guard progress > 0 else { return 0 }
		
		return width * progress
	}
	
	init(mediaItem: any MediaItem, width: CGFloat = LayoutConstants.artworkWidth, height: CGFloat = LayoutConstants.artworkHeight, scale: CGFloat = 1.0) {
		self.mediaItem = mediaItem
		self.width = width * scale
		self.height = height * scale
		self.cornerRadius = LayoutConstants.cornerRadius * (width / LayoutConstants.artworkWidth) * scale
	}
	
	private let progressBarHeight: CGFloat = 5
	
    var body: some View {
		RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
			.foregroundStyle(Color.clear)
			.onHover(perform: showButton)
			.frame(width: width, height: height)
			.overlay {
				VStack(alignment: .leading, spacing: 0) {
					Rectangle()
						.foregroundStyle(Color.clear)
						.frame(width: width, height: height - progressBarHeight)
					Rectangle()
						.foregroundStyle(Color.accentColor)
						.frame(width: progressWidth, height: progressBarHeight)
				}
				.clipShape(.rect(cornerRadius: cornerRadius, style: .continuous))
				.onHover(perform: showButton)
			}
			.overlay(alignment: .center) {
				if showPlayButton {
					PlayButton(mediaItem: mediaItem)
						.onHover(perform: showButton)
				}
			}
    }
	
	private func showButton(show: Bool) {
		withAnimation {
			showPlayButton = show
		}
	}
}
