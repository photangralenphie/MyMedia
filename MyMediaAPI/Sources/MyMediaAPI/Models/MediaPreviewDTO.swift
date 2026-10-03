//
// Copyright © 2026 MyMedia.
// Licensed under the MIT License.
//

import Foundation

public struct MediaPreviewDTO: Codable, Sendable {
	public let kind: ApiMediaKind
	public let id: UUID
	public let name: String
	public let year: Int?
	public let season: Int?
	public let episode: Int?
	public let numberOfItems: Int?
	public let previewArtworkURL: String?

	public init(
		kind: ApiMediaKind,
		id: UUID,
		name: String,
		year: Int? = nil,
		season: Int? = nil,
		episode: Int? = nil,
		numberOfItems: Int? = nil,
		previewArtworkURL: String? = nil
	) {
		self.kind = kind
		self.id = id
		self.name = name
		self.year = year
		self.season = season
		self.episode = episode
		self.numberOfItems = numberOfItems
		self.previewArtworkURL = previewArtworkURL
	}
}
