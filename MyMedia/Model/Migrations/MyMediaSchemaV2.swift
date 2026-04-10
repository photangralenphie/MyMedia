//
//  MyMediaSchemaV2.swift
//  MyMedia
//
//  Created by Jonas Helmer on 04.03.26.
//

import SwiftData

struct MyMediaSchemaV2: VersionedSchema {
	static let versionIdentifier = Schema.Version(2, 0, 0)

	static var models: [any PersistentModel.Type] {
		[
			TvShow.self,
			Episode.self,
			Movie.self,
			MediaCollection.self,
			Person.self
		]
	}
}
