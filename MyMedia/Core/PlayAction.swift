//
// Copyright © 2025 MyMedia.
// Licensed under the MIT License.
//

import SwiftData
import SwiftUI

enum PlayType: Codable {
	case play
	case resume
	case playAgain
	case playNextEpisode
	case resumeCurrentEpisode

	var text: LocalizedStringKey {
		switch self {
			case .play: "Play"
			case .resume: "Resume"
			case .playAgain: "Play Again"
			case .playNextEpisode: "Play next Episode"
			case .resumeCurrentEpisode: "Resume Current Episode"
		}
	}
}

struct PlayAction: Hashable, Codable {
	let identifiers: [PersistentIdentifier]
	let playType: PlayType
}
