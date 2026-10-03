//
// Copyright © 2026 MyMedia.
// Licensed under the MIT License.
//

import Foundation

public struct ApiEpisodeDTO: Codable, Sendable {
	public let id: UUID
	public let dateAdded: Date
	public let isWatched: Bool
	public let isFavorite: Bool
	public let isPinned: Bool
	public let progressMinutes: Int
	public let artworkURL: String?
	public let season: Int
	public let episode: Int
	public let title: String
	public let year: Int
	public let durationMinutes: Int
	public let releaseDate: Date
	public let episodeShortDescription: String?
	public let episodeLongDescription: String?
	public let credits: ApiCreditsDTO
	public let studio: String?
	public let network: String?
	public let rating: String?
	public let languages: [String]
	public let tvShow: MediaPreviewDTO

	public init(
		id: UUID,
		dateAdded: Date,
		isWatched: Bool,
		isFavorite: Bool,
		isPinned: Bool,
		progressMinutes: Int,
		artworkURL: String?,
		season: Int,
		episode: Int,
		title: String,
		year: Int,
		durationMinutes: Int,
		releaseDate: Date,
		episodeShortDescription: String?,
		episodeLongDescription: String?,
		credits: ApiCreditsDTO,
		studio: String?,
		network: String?,
		rating: String?,
		languages: [String],
		tvShow: MediaPreviewDTO
	) {
		self.id = id
		self.dateAdded = dateAdded
		self.isWatched = isWatched
		self.isFavorite = isFavorite
		self.isPinned = isPinned
		self.progressMinutes = progressMinutes
		self.artworkURL = artworkURL
		self.season = season
		self.episode = episode
		self.title = title
		self.year = year
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
