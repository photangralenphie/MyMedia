//
//  MyMediaMigrationPlan.swift
//  MyMedia
//
//  Created by Jonas Helmer on 04.03.26.
//

import Foundation
import SwiftData

struct MyMediaMigrationPlan: SchemaMigrationPlan {
	static var schemas: [any VersionedSchema.Type] {
		[MyMediaSchemaV1.self, MyMediaSchemaV2.self ]
	}

	static var stages: [MigrationStage] { [migrateV1toV2] }

	static let migrateV1toV2 = MigrationStage.custom(
		fromVersion: MyMediaSchemaV1.self,
		toVersion: MyMediaSchemaV2.self,
		willMigrate: { context in
			let shows = try context.fetch(FetchDescriptor<MyMediaSchemaV1.TvShow>())
			let episodes = try context.fetch(FetchDescriptor<MyMediaSchemaV1.Episode>())

			var assignedEpisodeIds: Set<PersistentIdentifier> = []
			for show in shows {
				for episode in show.episodes {
					assignedEpisodeIds.insert(episode.persistentModelID)
				}
			}

			let orphanedEpisodes = episodes.filter { !assignedEpisodeIds.contains($0.persistentModelID) }
			if !orphanedEpisodes.isEmpty {
				let unknownShow = MyMediaSchemaV1.TvShow(
					title: "Unknown Show",
					year: Calendar.current.component(.year, from: .now),
					genre: []
				)
				context.insert(unknownShow)
				for episode in orphanedEpisodes {
					unknownShow.episodes.append(episode)
				}
			}

			try context.save()
		},
		didMigrate: { context in
			try CreditsBuilder.rebuildCreditStore(context: context)
		}
	)
}
