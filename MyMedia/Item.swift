//
//  Item.swift
//  MyMedia
//
//  Created by Jonas Helmer on 27.03.25.
//

import Foundation
import SwiftData
import AppKit

protocol Watchable: Identifiable {
	var id: UUID { get }
	var title: String { get }
	var dateAdded: Date { get }
	var year: Int { get }
	var isWatched: Bool { get set }
	var artwork: Data? { get }
}

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
	
	init(title: String, year: Int, genre: String?, showDescription: String?, artwork: Data?) {
		self.title = title
		self.year = year
		self.genre = genre
		self.showDescription = showDescription
		self.artwork = artwork
	}
}

@Model
class Episode: Watchable {
	var id: UUID = UUID()
	var dateAdded = Date.now
	var isWatched: Bool = false
	
	var year: Int { Calendar.current.component(.year, from: releaseDate) }
	
	var artwork: Data?
	var season: Int
	var episode: Int
	var title: String
	var runtime: Int
	var releaseDate: Date
	var episodeShortDescription: String?
	var episodeLongDescription: String?
	var cast: [String]?
	var producers: [String]?
	var directors: [String]?
	var screenwriters: [String]?
	var studio: String?
	var network: String?
	var rating: String?
	var languages: [String]
	var url: URL
	
	init(artwork: Data?, season: Int, episode: Int, title: String, runtime: Int, releaseDate: Date, episodeShortDescription: String?, episodeLongDescription: String?, cast: [String]?, producers: [String]?, directors: [String]?, screenwriters: [String]?, studio: String?, network: String?, rating: String?, languages: [String], url: URL) {
		self.artwork = artwork
		self.season = season
		self.episode = episode
		self.title = title
		self.runtime = runtime
		self.releaseDate = releaseDate
		self.episodeShortDescription = episodeShortDescription
		self.episodeLongDescription = episodeLongDescription
		self.cast = cast
		self.producers = producers
		self.directors = directors
		self.screenwriters = screenwriters
		self.studio = studio
		self.network = network
		self.rating = rating
		self.languages = languages
		self.url = url
	}
}
