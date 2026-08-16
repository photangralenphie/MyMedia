//
// Copyright © 2025 MyMedia.
// Licensed under the MIT License.
//

import Foundation
import SwiftData

@Model
class Movie: IsWatchable, HasGenre, MediaItem, HasCredits {
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
	var title: String
	var genre: [String]
	var durationMinutes: Int
	var releaseDate: Date
	var shortDescription: String?
	var longDescription: String?
	@Relationship(deleteRule: .cascade, inverse: \Credits.movie)
	var credits: Credits?
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
		credits: Credits,
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
		self.credits = credits
		self.studio = studio
		self.hdVideoQuality = hdVideoQuality
		self.rating = rating
		self.languages = languages
	}
}
