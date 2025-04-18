//
//  TvShow.swift
//  MyMedia
//
//  Created by Jonas Helmer on 12.04.25.
//

import SwiftData
import Foundation

@Model
class TvShow: WatchableWithGenre {
	@Attribute(.unique) var id = UUID()
	var dateAdded = Date.now
	var title: String
	var year: Int
	var genre: [String]
	var showDescription: String?
	@Relationship(deleteRule: .cascade) var episodes: [Episode]
	var artwork: Data?
	
	@Transient var isWatched: Bool {
		get { episodes.allSatisfy(\.isWatched) }
		set { episodes.forEach { $0.isWatched = newValue } }
	}
	var isFavorite: Bool = false
	var isPinned: Bool = false
	
	@Transient var url: URL {
		// DON'T CALL IF TVSHOW HASN'T GOT ANY EPISODES
		episodes.filter { !$0.isWatched }.first?.url ?? episodes.first!.url
	}
	
	init(title: String, year: Int, genre: [String], showDescription: String?, episodes: [Episode] = [], artwork: Data?) {
		self.title = title
		self.year = year
		self.genre = genre
		self.showDescription = showDescription
		self.episodes = episodes
		self.artwork = artwork
	}
}
