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
	
	var text: String {
		if mediaItem.isWatched {
			return "Play Again"
		}
		
		switch mediaItem {
			case let tvShow as TvShow :
				if tvShow.episodes.allSatisfy({ !$0.isWatched }) {
					return "Play"
				}
				return "Play Next Episode"
			case let movie as Movie:
				if movie.progressMinutes == 0 {
					return "Play"
				}
				return "Resume"
			case let episode as Episode:
				if episode.progressMinutes == 0 {
					return "Play"
				}
				return "Resume"
			default:
				return "Play"
		}
	}
	
	@AppStorage(PreferenceKeys.useInAppPlayer) private var useInAppPlayer: Bool = true
	@Environment(\.openWindow) private var openWindow
	
    var body: some View {
		Button(text, systemImage: "play.fill") { mediaItem.play(useInAppPlayer: useInAppPlayer, openWindow: openWindow) }
			.buttonStyle(iOSBorderedProminentForMacOS())
    }
}
