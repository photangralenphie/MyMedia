//
//  Movie.swift
//  MyMedia
//
//  Created by Jonas Helmer on 12.04.25.
//

import SwiftData
import Foundation

@Model
class Movie: Watchable {
	var id: UUID = UUID()
	var dateAdded = Date.now
	var isWatched: Bool = false
	var isFavorite: Bool = false
	var isPinned: Bool = false
	
	var year: Int { Calendar.current.component(.year, from: releaseDate) }
	
	var artwork: Data?
	var title: String
	var genre: String?
	var runtime: Int
	var releaseDate: Date
	var shortDescription: String?
	var longDescription: String?
	var cast: [String]?
	var producers: [String]?
	var executiveProducers: [String]?
	var directors: [String]?
	var coDirectors: [String]?
	var screenwriters: [String]?
	var studio: String?
	var hdVideoQuality: HDVideoQuality?
	var rating: String?
	var languages: [String]
	var url: URL
	
	init(artwork: Data?, title: String, genre: String?, runtime: Int, releaseDate: Date, shortDescription: String?, longDescription: String?, cast: [String]?, producers: [String]?, executiveProducers: [String]?, directors: [String]?, coDirectors: [String]?, screenwriters: [String]?, studio: String?, hdVideoQuality: HDVideoQuality?, rating: String?, languages: [String], url: URL) {
		self.artwork = artwork
		self.title = title
		self.genre = genre
		self.runtime = runtime
		self.releaseDate = releaseDate
		self.shortDescription = shortDescription
		self.longDescription = longDescription
		self.cast = cast
		self.producers = producers
		self.executiveProducers = executiveProducers
		self.directors = directors
		self.coDirectors = coDirectors
		self.screenwriters = screenwriters
		self.studio = studio
		self.hdVideoQuality = hdVideoQuality
		self.rating = rating
		self.languages = languages
		self.url = url
	}
}
