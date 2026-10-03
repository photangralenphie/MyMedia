//
// Copyright © 2026 MyMedia.
// Licensed under the MIT License.
//

/// Values that can be changed on an existing movie, TV show, or episode.
///
/// Omitted properties keep their current values. `progressMinutes` only
/// applies to movies and episodes.
public struct ApiMediaItemUpdateRequest: Codable, Sendable {
	public let isWatched: Bool?
	public let isFavorite: Bool?
	public let isPinned: Bool?
	public let progressMinutes: Int?

	public init(
		isWatched: Bool? = nil,
		isFavorite: Bool? = nil,
		isPinned: Bool? = nil,
		progressMinutes: Int? = nil
	) {
		self.isWatched = isWatched
		self.isFavorite = isFavorite
		self.isPinned = isPinned
		self.progressMinutes = progressMinutes
	}
}
