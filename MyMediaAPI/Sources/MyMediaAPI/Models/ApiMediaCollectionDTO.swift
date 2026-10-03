//
// Copyright © 2026 MyMedia.
// Licensed under the MIT License.
//

import Foundation

public struct ApiMediaCollectionDTO: Codable, Sendable {
	public let id: UUID
	public let title: String
	public let collectionDescription: String?
	public let artworkURL: String?
	public let dateAdded: Date
	public let isPinned: Bool
	public let isWatched: Bool
	public let numberOfItems: Int
	public let items: [MediaPreviewDTO]

	public init(
		id: UUID,
		title: String,
		collectionDescription: String?,
		artworkURL: String?,
		dateAdded: Date,
		isPinned: Bool,
		isWatched: Bool,
		numberOfItems: Int,
		items: [MediaPreviewDTO]
	) {
		self.id = id
		self.title = title
		self.collectionDescription = collectionDescription
		self.artworkURL = artworkURL
		self.dateAdded = dateAdded
		self.isPinned = isPinned
		self.isWatched = isWatched
		self.numberOfItems = numberOfItems
		self.items = items
	}
}
