//
// Copyright © 2026 MyMedia.
// Licensed under the MIT License.
//

import Foundation

public struct ApiMovieDTO: Codable, Sendable {
	public let id: UUID
	public let dateAdded: Date
	public let isWatched: Bool
	public let isFavorite: Bool
	public let isPinned: Bool
	public let progressMinutes: Int
	public let artworkURL: String?
	public let title: String
	public let year: Int
	public let genre: [String]
	public let durationMinutes: Int
	public let releaseDate: Date
	public let shortDescription: String?
	public let longDescription: String?
	public let credits: ApiCreditsDTO
	public let studio: String?
	public let hdVideoQuality: String?
	public let rating: String?
	public let languages: [String]

	public init(
		id: UUID,
		dateAdded: Date,
		isWatched: Bool,
		isFavorite: Bool,
		isPinned: Bool,
		progressMinutes: Int,
		artworkURL: String?,
		title: String,
		year: Int,
		genre: [String],
		durationMinutes: Int,
		releaseDate: Date,
		shortDescription: String?,
		longDescription: String?,
		credits: ApiCreditsDTO,
		studio: String?,
		hdVideoQuality: String?,
		rating: String?,
		languages: [String]
	) {
		self.id = id
		self.dateAdded = dateAdded
		self.isWatched = isWatched
		self.isFavorite = isFavorite
		self.isPinned = isPinned
		self.progressMinutes = progressMinutes
		self.artworkURL = artworkURL
		self.title = title
		self.year = year
		self.genre = genre
		self.durationMinutes = durationMinutes
		self.releaseDate = releaseDate
		self.shortDescription = shortDescription
		self.longDescription = longDescription
		self.credits = credits
		self.studio = studio
		self.hdVideoQuality = hdVideoQuality
		self.rating = rating
		self.languages = languages
	}
}
