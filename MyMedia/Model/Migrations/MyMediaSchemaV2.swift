//
// Copyright © 2026 MyMedia.
// Licensed under the MIT License.
//

import SwiftData

struct MyMediaSchemaV2: VersionedSchema {
	static let versionIdentifier = Schema.Version(2, 0, 0)

	static var models: [any PersistentModel.Type] {
		[
			TvShow.self,
			Credits.self,
			Episode.self,
			Movie.self,
			MediaCollection.self,
			Person.self
		]
	}
}
