//
//  TvShow.swift
//  MyMedia
//
//  Created by Jonas Helmer on 12.04.25.
//

import SwiftData
import Foundation

@Model
class TvShow: Watchable {
	var id = UUID()
	var dateAdded = Date.now
	var title: String
	var year: Int
	var genre: String?
	var showDescription: String?
	@Relationship(deleteRule: .cascade) var episodes: [Episode] = []
	var artwork: Data?
	
	var isWatched: Bool {
		get { episodes.allSatisfy(\.isWatched) }
		set { episodes.forEach { $0.isWatched = newValue } }
	}
	var isFavorite: Bool = false
	var isPinned: Bool = false
	
	init(title: String, year: Int, genre: String?, showDescription: String?, artwork: Data?) {
		self.title = title
		self.year = year
		self.genre = genre
		self.showDescription = showDescription
		self.artwork = artwork
	}
}
