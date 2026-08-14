//
//  Episode.swift
//  MyMedia
//
//  Created by Jonas Helmer on 12.04.25.
//

import Foundation
import SwiftData

@Model
class Episode: IsWatchable, MediaItem, HasCredits {

	@Attribute(.unique)
	var id: UUID = UUID()
	var dateAdded = Date.now
	var isWatched: Bool = false
	var isFavorite: Bool = false
	var isPinned: Bool = false
	var progressMinutes: Int = 0

	@Transient
	var year: Int {
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
	@Relationship(deleteRule: .cascade, inverse: \Credits.episode)
	var credits: Credits?
	var studio: String?
	var network: String?
	var rating: String?
	var languages: [String]
	var tvShow: TvShow

	init(
		artwork: Data?,
		season: Int,
		episode: Int,
		title: String,
		durationMinutes: Int,
		releaseDate: Date,
		episodeShortDescription: String?,
		episodeLongDescription: String?,
		credits: Credits,
		studio: String?,
		network: String?,
		rating: String?,
		languages: [String],
		tvShow: TvShow
	) {
		self.artwork = artwork
		self.season = season
		self.episode = episode
		self.title = title
		self.durationMinutes = durationMinutes
		self.releaseDate = releaseDate
		self.episodeShortDescription = episodeShortDescription
		self.episodeLongDescription = episodeLongDescription
		self.credits = credits
		self.studio = studio
		self.network = network
		self.rating = rating
		self.languages = languages
		self.tvShow = tvShow
	}
}
