//
// Copyright © 2026 MyMedia.
// Licensed under the MIT License.
//

import Foundation

/// Values used to create a media collection.
public struct ApiCreateMediaCollectionRequest: Codable, Sendable {
	public let title: String
	public let collectionDescription: String?
	public let mediaItemIDs: [UUID]?

	public init(title: String, collectionDescription: String? = nil, mediaItemIDs: [UUID]? = nil) {
		self.title = title
		self.collectionDescription = collectionDescription
		self.mediaItemIDs = mediaItemIDs
	}
}

/// Media items to add to or remove from an existing collection.
public struct ApiMediaCollectionUpdateRequest: Codable, Sendable {
	public let add: [UUID]?
	public let remove: [UUID]?
	public let isPinned: Bool?

	public init(add: [UUID]? = nil, remove: [UUID]? = nil, isPinned: Bool? = nil) {
		self.add = add
		self.remove = remove
		self.isPinned = isPinned
	}
}
