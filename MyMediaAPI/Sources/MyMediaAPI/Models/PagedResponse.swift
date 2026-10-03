//
// Copyright © 2026 MyMedia.
// Licensed under the MIT License.
//

import Foundation

public struct PagedResponse<Item: Codable & Sendable>: Codable, Sendable {
	public let items: [Item]
	public let page: Int
	public let perPage: Int
	public let totalItems: Int
	public let totalPages: Int

	public init(items: [Item], page: Int, perPage: Int, totalItems: Int) {
		self.items = items
		self.page = page
		self.perPage = perPage
		self.totalItems = totalItems
		totalPages = totalItems == 0 ? 0 : Int(ceil(Double(totalItems) / Double(perPage)))
	}
}
