//
// Copyright © 2026 MyMedia.
// Licensed under the MIT License.
//

import Foundation

internal struct ApiDocumentation {
	internal static let landingPath = "/docs/documentation/mymediaapi/"

	internal static let openAPISpecification: String? = {
		guard let url = Bundle.module.url(forResource: "openapi", withExtension: "yaml") else { return nil }
		return try? String(contentsOf: url, encoding: .utf8)
	}()

	internal static let scalarDocs: String? = {
		guard let url = Bundle.module.url(forResource: "scalarDocs", withExtension: "html") else { return nil }
		return try? String(contentsOf: url, encoding: .utf8)
	}()

	internal static var documentationDirectory: URL? {
		guard let resourcesDirectory = Bundle.main.resourceURL else { return nil }
		let url = resourcesDirectory.appendingPathComponent("documentation", isDirectory: true)
		guard FileManager.default.fileExists(atPath: url.path) else { return nil }
		return url
	}

	private init() {}
}
