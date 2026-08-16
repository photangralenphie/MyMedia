//
// Copyright © 2025 MyMedia.
// Licensed under the MIT License.
//

import Foundation
import SwiftData

fileprivate let miniSeriesGenres: Set<String> = [
	// English
	"Mini-Series", "Mini Series", "Limited-Series", "Limited Series",
	// German
	"Mini Serie", "Miniserie", "Mini-Serie"
]

@Model
class TvShow: HasGenre {
	@Attribute(.unique)
	var id = UUID()

	var dateAdded = Date.now
	var title: String
	var year: Int
	var genre: [String]
	var showDescription: String?
	var artwork: Data?
	var isFavorite: Bool = false
	var isPinned: Bool = false

	@Relationship(deleteRule: .cascade, inverse: \Episode.tvShow)
	var episodes: [Episode]

	@Transient
	var isWatched: Bool {
		get { episodes.allSatisfy(\.isWatched) }
		set { episodes.forEach { $0.isWatched = newValue } }
	}

	@Transient
	var networks: [String] {
		Array(Set(episodes.compactMap(\.network)))
	}

	@Transient
	var isMiniSeries: Bool {
		!Set(genre).isDisjoint(with: miniSeriesGenres)
	}

	init(title: String, year: Int, genre: [String], showDescription: String?, episodes: [Episode] = [], artwork: Data?) {
		self.title = title
		self.year = year
		self.genre = genre
		self.showDescription = showDescription
		self.episodes = episodes
		self.artwork = artwork
	}

	func findEpisodesToPlay() -> [Episode] {
		let sortedEpisodes = self.episodes.sorted {
			if $0.season == $1.season {
				return $0.episode < $1.episode
			}
			return $0.season < $1.season
		}

		let unwatched = sortedEpisodes.filter { !$0.isWatched }
		if !unwatched.isEmpty {
			return unwatched
		}
			return sortedEpisodes
	}
}
