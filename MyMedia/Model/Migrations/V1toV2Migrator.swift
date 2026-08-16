//
//  V1toV2Migrator.swift
//  MyMedia
//
//  Created by Jonas Helmer on 09.08.26.
//

import Foundation
import SwiftData
import Synchronization

struct V1toV2Migrator {
	private struct LegacyCredits: Sendable {
		var movies: [UUID: CreditsDTO] = [:]
		var episodes: [UUID: CreditsDTO] = [:]
	}

	private static let legacyCredits = Mutex(LegacyCredits())

	public static let migrate = MigrationStage.custom(
		fromVersion: MyMediaSchemaV1.self,
		toVersion: MyMediaSchemaV2.self,
		willMigrate: willMigrate,
		didMigrate: didMigrate
	)

	@Sendable
	private static func willMigrate(context: ModelContext) throws {
		let movies = try context.fetch(FetchDescriptor<MyMediaSchemaV1.Movie>())
		let shows = try context.fetch(FetchDescriptor<MyMediaSchemaV1.TvShow>())
		let episodes = try context.fetch(FetchDescriptor<MyMediaSchemaV1.Episode>())

		let movieCredits = Dictionary(
			uniqueKeysWithValues: movies.map { movie in (
				movie.id,
				CreditsDTO(
					cast: movie.cast,
					directors: movie.directors,
					coDirectors: movie.coDirectors,
					screenwriters: movie.screenwriters,
					producers: movie.producers,
					executiveProducers: movie.executiveProducers,
					composer: movie.composer
				))
			}
		)

		let episodeCredits = Dictionary(
			uniqueKeysWithValues: episodes.map { episode in (
				episode.id,
				CreditsDTO(
					cast: episode.cast,
					directors: episode.directors,
					coDirectors: episode.coDirectors,
					screenwriters: episode.screenwriters,
					producers: episode.producers,
					executiveProducers: episode.executiveProducers,
					composer: episode.composer
				))
			}
		)

		Self.legacyCredits.withLock { credits in
			credits.movies = movieCredits
			credits.episodes = episodeCredits
		}

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
	}

	@Sendable
	private static func didMigrate(context: ModelContext) throws {
		let credits = Self.legacyCredits.withLock { credits in
			let savedCredits = credits
			credits = LegacyCredits()
			return savedCredits
		}
		try CreditsBuilder.rebuildCredits(
			movies: credits.movies,
			episodes: credits.episodes,
			context: context
		)
	}
}
