//
//  PlayButton.swift
//  MyMedia
//
//  Created by Jonas Helmer on 12.04.25.
//

import SwiftUI
import AwesomeSwiftyComponents

struct PlayButton: View {
	
	let watchable: any MediaItem
	
	var text: String {
		if watchable.isWatched {
			return "Play Again"
		}
		
		switch watchable {
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
		Button(text, systemImage: "play.fill") { play(watchable: watchable) }
			.buttonStyle(iOSBorderedProminentForMacOS())
    }
	
	func play(watchable: any MediaItem) {
		if useInAppPlayer {
			switch watchable {
				case let tvShow as TvShow :
					openWindow(value: findEpisodesToPlay(for: tvShow).map(\.persistentModelID))
				case let movie as Movie:
					openWindow(value: [movie.persistentModelID])
				case let episode as Episode:
					openWindow(value: [episode.persistentModelID])
				default: break
			}
		} else {
			NSWorkspace.shared.open(watchable.url)
		}
	}
	
	func findEpisodesToPlay(for tvShow: TvShow) -> [Episode] {
		let unwatched = tvShow.episodes.filter{ !$0.isWatched }
		if(unwatched.count > 0) {
			return unwatched
		} else {
			return tvShow.episodes
		}
	}
}
