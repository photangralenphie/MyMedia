//
//  PlayButton.swift
//  MyMedia
//
//  Created by Jonas Helmer on 12.04.25.
//

import SwiftUI
import AwesomeSwiftyComponents

struct PlayButton: View {
	
	let mediaItem: any MediaItem
	
	var playType: PlayType {
		if mediaItem.isWatched {
			return PlayType.playAgain
		}
		
		switch mediaItem {
			case let tvShow as TvShow :
				if tvShow.episodes.allSatisfy({ !$0.isWatched }) {
					return PlayType.play
				}
				if let firstUnwatchedEpisode = tvShow.episodes.filter({ !$0.isWatched }).first {
					if firstUnwatchedEpisode.progressMinutes != 0 {
						return PlayType.resumeCurrentEpisode
					}
				}
				return PlayType.playNextEpisode
			case let movie as Movie:
				if movie.progressMinutes == 0 {
					return PlayType.play
				}
				return PlayType.resume
			case let episode as Episode:
				if episode.progressMinutes == 0 {
					return PlayType.play
				}
				return PlayType.resume
			default:
				return PlayType.play
		}
	}
	
	@AppStorage(PreferenceKeys.useInAppPlayer) private var useInAppPlayer: Bool = true
	@Environment(\.openWindow) private var openWindow
	@State private var isHovered: Bool = false
	
    var body: some View {

		if #available(macOS 26.0, *) {
			Button(playType.text, systemImage: "play.fill", action: playAction)
				.glassEffect(.clear.tint(.accentColor.opacity(isHovered ? 1 : 0.7)).interactive())
				.onHover(perform: onHover)
		} else {
			Button(playType.text, systemImage: "play.fill", action: playAction)
				.buttonStyle(iOSBorderedProminentForMacOS())
		}

    }
	
	func playAction() {
		if useInAppPlayer {
			mediaItem.play(playType: playType, openWindow: openWindow)
		} else {
			mediaItem.playWithDefaultPlayer()
		}
	}
	
	private func onHover(isHovering: Bool) {
		withAnimation {
			isHovered = isHovering
		}
	}
}
