//
// Copyright © 2026 MyMedia.
// Licensed under the MIT License.
//

public struct ApiListFilters: Sendable {
	public var year: ClosedRange<Int>?
	public var minimumLength: Int?
	public var maximumLength: Int?
	public var isFavorite: Bool?
	public var isWatched: Bool?
	public var genre: [String]

	public init(
		year: ClosedRange<Int>? = nil,
		minimumLength: Int? = nil,
		maximumLength: Int? = nil,
		isFavorite: Bool? = nil,
		isWatched: Bool? = nil,
		genre: [String] = []
	) {
		self.year = year
		self.minimumLength = minimumLength
		self.maximumLength = maximumLength
		self.isFavorite = isFavorite
		self.isWatched = isWatched
		self.genre = genre
	}
}
