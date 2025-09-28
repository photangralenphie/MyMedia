//
//  PlayAction.swift
//  MyMedia
//
//  Created by Jonas Helmer on 28.09.25.
//

import SwiftUI
import SwiftData

enum PlayType: Codable {
	case play
	case resume
	case playAgain
	case playNextEpisode
	case resumeCurrentEpisode
	
	var text: LocalizedStringKey {
		switch self {
			case .play:
				return "Play"
			case .resume:
				return "Resume"
			case .playAgain:
				return "Play Again"
			case .playNextEpisode:
				return "Play next Episode"
			case .resumeCurrentEpisode:
				return "Resume Current Episode"
		}
	}
}

struct PlayAction: Hashable, Codable {
	let identifiers: [PersistentIdentifier]
	let playType: PlayType
}

