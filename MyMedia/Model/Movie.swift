//
//  Movie.swift
//  MyMedia
//
//  Created by Jonas Helmer on 12.04.25.
//

import SwiftData
import Foundation

@Model
class Movie: IsWatchable, HasGenre, HasCredits {
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
	var title: String
	var genre: [String]
	var durationMinutes: Int
	var releaseDate: Date
	var shortDescription: String?
	var longDescription: String?
	var cast: [String]
	var producers: [String]
	var executiveProducers: [String]
	var directors: [String]
	var coDirectors: [String]
	var screenwriters: [String]
	var composer: String?
	var studio: String?
	var hdVideoQuality: HDVideoQuality?
	var rating: String?
	var languages: [String]
	
	init(
		artwork: Data?,
		title: String,
		genre: [String],
		durationMinutes: Int,
		releaseDate: Date,
		shortDescription: String?,
		longDescription: String?,
		cast: [String],
		producers: [String],
		executiveProducers: [String],
		directors: [String],
		coDirectors: [String],
		screenwriters: [String],
		composer: String?,
		studio: String?,
		hdVideoQuality: HDVideoQuality?,
		rating: String?,
		languages: [String],
	) {
		self.artwork = artwork
		self.title = title
		self.genre = genre
		self.durationMinutes = durationMinutes
		self.releaseDate = releaseDate
		self.shortDescription = shortDescription
		self.longDescription = longDescription
		self.cast = cast
		self.producers = producers
		self.executiveProducers = executiveProducers
		self.directors = directors
		self.coDirectors = coDirectors
		self.screenwriters = screenwriters
		self.composer = composer
		self.studio = studio
		self.hdVideoQuality = hdVideoQuality
		self.rating = rating
		self.languages = languages
	}
}
