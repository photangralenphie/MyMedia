//
// Copyright © 2026 MyMedia.
// Licensed under the MIT License.
//

import Foundation

public struct ResolvedVideoFile: Sendable {
	public let url: URL
	public let title: String

	public init(url: URL, title: String) {
		self.url = url
		self.title = title
	}
}
