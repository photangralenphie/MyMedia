//
//  Episode.swift
//  MyMedia
//
//  Created by Jonas Helmer on 12.04.25.
//

import Foundation
import SwiftData

@Model
class Episode: IsWatchable, HasCredits {
	@Attribute(.unique) var id: UUID = UUID()
	var dateAdded = Date.now
	var isWatched: Bool = false
	var isFavorite: Bool = false
	var isPinned: Bool = false
	var progressMinutes: Int = 0
	
	@Transient var year: Int {
		Calendar.current.component(.year, from: releaseDate)
	}
	
	var artwork: Data?
	var season: Int
	var episode: Int
	var title: String
	var durationMinutes: Int
	var releaseDate: Date
	var episodeShortDescription: String?
	var episodeLongDescription: String?
	var cast: [String]
	var producers: [String]
	var executiveProducers: [String]
	var directors: [String]
	var coDirectors: [String]
	var screenwriters: [String]
	var composer: String?
	var studio: String?
	var network: String?
	var rating: String?
	var languages: [String]
	
	init(
		artwork: Data?,
		season: Int,
		episode: Int,
		title: String,
		durationMinutes: Int,
		releaseDate: Date,
		episodeShortDescription: String?,
		episodeLongDescription: String?,
		cast: [String],
		producers: [String],
		executiveProducers: [String],
		directors: [String],
		coDirectors: [String],
		screenwriters: [String],
		composer: String?,
		studio: String?,
		network: String?,
		rating: String?,
		languages: [String]
	) {
		self.artwork = artwork
		self.season = season
		self.episode = episode
		self.title = title
		self.durationMinutes = durationMinutes
		self.releaseDate = releaseDate
		self.episodeShortDescription = episodeShortDescription
		self.episodeLongDescription = episodeLongDescription
		self.cast = cast
		self.producers = producers
		self.executiveProducers = executiveProducers
		self.directors = directors
		self.coDirectors = coDirectors
		self.screenwriters = screenwriters
		self.composer = composer
		self.studio = studio
		self.network = network
		self.rating = rating
		self.languages = languages
	}
}
