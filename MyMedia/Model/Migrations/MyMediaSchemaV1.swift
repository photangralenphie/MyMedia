//
//  MyMediaSchemaV1.swift
//  MyMedia
//
//  Created by Jonas Helmer on 04.03.26.
//

import Foundation
import SwiftData

struct MyMediaSchemaV1: VersionedSchema {
	static let versionIdentifier = Schema.Version(1, 0, 0)

	static var models: [any PersistentModel.Type] {
		[
			TvShow.self,
			Episode.self,
			Movie.self,
			MediaCollection.self
		]
	}

	@Model
	final class TvShow {
		@Attribute(.unique) var id: UUID = UUID()
		var dateAdded: Date = Date.now
		var title: String
		var year: Int
		var genre: [String]
		var showDescription: String?
		var artwork: Data?
		var isFavorite: Bool = false
		var isPinned: Bool = false
		@Relationship(deleteRule: .cascade) var episodes: [Episode]

		init(
			title: String,
			year: Int,
			genre: [String],
			showDescription: String? = nil,
			artwork: Data? = nil,
			episodes: [Episode] = []
		) {
			self.title = title
			self.year = year
			self.genre = genre
			self.showDescription = showDescription
			self.artwork = artwork
			self.episodes = episodes
		}
	}

	@Model
	final class Episode {
		@Attribute(.unique) var id: UUID = UUID()
		var dateAdded: Date = Date.now
		var isWatched: Bool = false
		var isFavorite: Bool = false
		var isPinned: Bool = false
		var progressMinutes: Int = 0
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

	@Model
	final class Movie {
		@Attribute(.unique) var id: UUID = UUID()
		var dateAdded: Date = Date.now
		var isWatched: Bool = false
		var isFavorite: Bool = false
		var isPinned: Bool = false
		var progressMinutes: Int = 0
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
			languages: [String]
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

	@Model
	final class MediaCollection {
		@Attribute(.unique) var id: UUID = UUID()
		var title: String
		var collectionDescription: String?
		var artwork: Data?
		private var tvShows: [TvShow] = []
		private var movies: [Movie] = []
		private var episodes: [Episode] = []
		var dateAdded: Date = Date.now
		var isPinned: Bool = false
		var sort: SortOption = SortOption.title
		private var viewPreferenceRawValue: Int = 0
		var useSections: Bool = true

		init(title: String, artwork: Data?) {
			self.title = title
			self.artwork = artwork
		}
	}
}
