//
//  TvShow.swift
//  MyMedia
//
//  Created by Jonas Helmer on 12.04.25.
//

import SwiftData
import Foundation

@Model
class TvShow: HasGenre {
	@Attribute(.unique) var id = UUID()
	
	var dateAdded = Date.now
	var title: String
	var year: Int
	var genre: [String]
	var showDescription: String?
	var artwork: Data?
	var isFavorite: Bool = false
	var isPinned: Bool = false
	
	@Relationship(deleteRule: .cascade) var episodes: [Episode]
	
	@Transient var isWatched: Bool {
		get { episodes.allSatisfy(\.isWatched) }
		set { episodes.forEach { $0.isWatched = newValue } }
	}
	
	@Transient var networks: [String] {
		return Array(Set(episodes.compactMap(\.network)))
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
		let unwatched = self.episodes.filter{ !$0.isWatched }
		if(unwatched.count > 0) {
			return unwatched
		} else {
			return self.episodes
		}
	}
}
