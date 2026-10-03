//
// Copyright © 2026 MyMedia.
// Licensed under the MIT License.
//

import Foundation

public struct ApiTvShowDTO: Codable, Sendable {
	public let id: UUID
	public let dateAdded: Date
	public let title: String
	public let year: Int
	public let genre: [String]
	public let showDescription: String?
	public let artworkURL: String?
	public let isFavorite: Bool
	public let isPinned: Bool
	public let isWatched: Bool
	public let networks: [String]
	public let isMiniSeries: Bool
	public let durationMinutes: Int
	public let episodes: [MediaPreviewDTO]

	public init(
		id: UUID,
		dateAdded: Date,
		title: String,
		year: Int,
		genre: [String],
		showDescription: String?,
		artworkURL: String?,
		isFavorite: Bool,
		isPinned: Bool,
		isWatched: Bool,
		networks: [String],
		isMiniSeries: Bool,
		durationMinutes: Int,
		episodes: [MediaPreviewDTO]
	) {
		self.id = id
		self.dateAdded = dateAdded
		self.title = title
		self.year = year
		self.genre = genre
		self.showDescription = showDescription
		self.artworkURL = artworkURL
		self.isFavorite = isFavorite
		self.isPinned = isPinned
		self.isWatched = isWatched
		self.networks = networks
		self.isMiniSeries = isMiniSeries
		self.durationMinutes = durationMinutes
		self.episodes = episodes
	}
}
