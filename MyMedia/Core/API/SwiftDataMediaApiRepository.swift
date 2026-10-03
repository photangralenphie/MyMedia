//
// Copyright © 2026 MyMedia.
// Licensed under the MIT License.
//

import AppKit
import AwesomeSwiftyComponents
import Foundation
import MyMediaAPI
import SwiftData

@MainActor
class SwiftDataMediaApiRepository: MediaApiRepository {
	private let modelContext: ModelContext

	public init(modelContainer: ModelContainer) {
		modelContext = modelContainer.mainContext
	}

	func appearance() -> ApiAppearanceDTO {
		let appearance = NSApplication.shared.effectiveAppearance
		let colorScheme: ApiColorScheme = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua ? .dark : .light
		let accentColor = NSColor.controlAccentColor
		var accentColorHex = "#FFFFFF"
		appearance.performAsCurrentDrawingAppearance {
			accentColorHex = accentColor.hex ?? accentColorHex
		}

		return ApiAppearanceDTO( colorScheme: colorScheme, accentColor: accentColorHex )
	}

	func movies(filters: ApiListFilters, page: Int, perPage: Int) throws -> PagedResponse<MediaPreviewDTO> {
		let movies = try modelContext.fetch(FetchDescriptor<Movie>())
			.filter { movie in
				let filterValue = FilterValues(year: movie.year, length: movie.durationMinutes, isFavorite: movie.isFavorite, isWatched: movie.isWatched, genres: movie.genre)
				return matchesCommonFilters(filterValue, filters: filters)
			}
			.sorted(by: titleSort)
		return paged(movies.map(\.previewDTO), page: page, perPage: perPage)
	}

	func tvShows(filters: ApiListFilters, page: Int, perPage: Int) throws -> PagedResponse<MediaPreviewDTO> {
		let tvShows = try modelContext.fetch(FetchDescriptor<TvShow>())
			.filter { show in
				let length = show.episodes.reduce(0) { $0 + $1.durationMinutes }
				let filterValues = FilterValues(year: show.year, length: length, isFavorite: show.isFavorite, isWatched: show.isWatched, genres: show.genre)
				return matchesCommonFilters(filterValues, filters: filters)
			}
			.sorted(by: titleSort)

		return paged(tvShows.map(\.previewDTO), page: page, perPage: perPage)
	}

	func collections(page: Int, perPage: Int) throws -> PagedResponse<MediaPreviewDTO> {
		let collections = try modelContext.fetch(FetchDescriptor<MediaCollection>())
			.sorted(by: titleSort)

		return paged(collections.map(\.previewDTO), page: page, perPage: perPage)
	}

	func movie(id: UUID) throws -> ApiMovieDTO? {
		try modelContext.fetch(FetchDescriptor<Movie>()).first { $0.id == id }?.DTO
	}

	func tvShow(id: UUID) throws -> ApiTvShowDTO? {
		try modelContext.fetch(FetchDescriptor<TvShow>()).first { $0.id == id }?.DTO
	}

	func episode(id: UUID) throws -> ApiEpisodeDTO? {
		try modelContext.fetch(FetchDescriptor<Episode>()).first { $0.id == id }?.DTO
	}

	func person(name: String) throws -> ApiPersonDTO? {
		try modelContext.fetch(FetchDescriptor<Person>()).first { $0.name.compare(name, options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive]) == .orderedSame }?.DTO
	}

	func collection(id: UUID) throws -> ApiMediaCollectionDTO? {
		try modelContext.fetch(FetchDescriptor<MediaCollection>()).first { $0.id == id }?.DTO
	}

	func updateMovie(id: UUID, with update: ApiMediaItemUpdateRequest) throws -> ApiMovieDTO? {
		guard let movie = try modelContext.fetch(FetchDescriptor<Movie>()).first(where: { $0.id == id }) else { return nil }
		if let progressMinutes = update.progressMinutes {
			guard progressMinutes <= movie.durationMinutes else {
				throw MediaApiMutationError.progressExceedsDuration(durationMinutes: movie.durationMinutes)
			}
			movie.progressMinutes = progressMinutes
		}

		if let isWatched = update.isWatched { movie.isWatched = isWatched }
		if let isFavorite = update.isFavorite { movie.isFavorite = isFavorite }
		if let isPinned = update.isPinned { movie.isPinned = isPinned }

		try modelContext.save()
		return movie.DTO
	}

	func updateTvShow(id: UUID, with update: ApiMediaItemUpdateRequest) throws -> ApiTvShowDTO? {
		guard let tvShow = try modelContext.fetch(FetchDescriptor<TvShow>()).first(where: { $0.id == id }) else { return nil }

		if let isWatched = update.isWatched { tvShow.isWatched = isWatched }
		if let isFavorite = update.isFavorite { tvShow.isFavorite = isFavorite }
		if let isPinned = update.isPinned { tvShow.isPinned = isPinned }

		try modelContext.save()
		return tvShow.DTO
	}

	func updateEpisode(id: UUID, with update: ApiMediaItemUpdateRequest) throws -> ApiEpisodeDTO? {
		guard let episode = try modelContext.fetch(FetchDescriptor<Episode>()).first(where: { $0.id == id }) else { return nil }

		if let progressMinutes = update.progressMinutes {
			guard progressMinutes <= episode.durationMinutes else {
				throw MediaApiMutationError.progressExceedsDuration(durationMinutes: episode.durationMinutes)
			}
			episode.progressMinutes = progressMinutes
		}

		if let isWatched = update.isWatched { episode.isWatched = isWatched }
		if let isFavorite = update.isFavorite { episode.isFavorite = isFavorite }
		if let isPinned = update.isPinned { episode.isPinned = isPinned }

		try modelContext.save()
		return episode.DTO
	}

	func createCollection(from request: ApiCreateMediaCollectionRequest) throws -> ApiMediaCollectionDTO {
		let initialItems = try mediaItems(ids: request.mediaItemIDs ?? [])
		let title = request.title.trimmingCharacters(in: .whitespacesAndNewlines)

		let collection = MediaCollection(title: title, artwork: nil)
		collection.collectionDescription = request.collectionDescription
		initialItems.forEach(collection.addMediaItem)

		modelContext.insert(collection)
		try modelContext.save()

		return collection.DTO
	}

	func updateCollection(id: UUID, with update: ApiMediaCollectionUpdateRequest) throws -> ApiMediaCollectionDTO? {
		guard let collection = try modelContext.fetch(FetchDescriptor<MediaCollection>()).first(where: { $0.id == id }) else {return nil}

		let additions = try mediaItems(ids: update.add ?? [])
		let removals = try mediaItems(ids: update.remove ?? [])

		additions.forEach(collection.addMediaItem)
		removals.forEach(collection.removeMediaItem)

		if let isPinned = update.isPinned { collection.isPinned = isPinned }

		try modelContext.save()
		return collection.DTO
	}

	func search(query: String, scope: ApiSearchScope, page: Int, perPage: Int) throws -> PagedResponse<MediaPreviewDTO> {
		guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
			return paged([], page: page, perPage: perPage)
		}

		var results: [MediaPreviewDTO] = []
		let movies = try modelContext.fetch(FetchDescriptor<Movie>())
			.filter { matchesSearch(movie: $0, query: query, scope: scope) }
		results.append(contentsOf: movies.map(\.previewDTO))

		let tvShows = try modelContext.fetch(FetchDescriptor<TvShow>())
			.filter { matchesSearch(tvShow: $0, query: query, scope: scope) }
		results.append(contentsOf: tvShows.map(\.previewDTO))

		let episodes = try modelContext.fetch(FetchDescriptor<Episode>())
			.filter { matchesSearch(episode: $0, query: query, scope: scope) }
		results.append(contentsOf: episodes.map(\.previewDTO))

		results.sort { $0.name.localizedStandardCompare($1.name) == .orderedAscending }

		return paged(results, page: page, perPage: perPage)
	}

	func genres(kind: GenreMediaKind) throws -> [String] {
		var genres = Set<String>()
		if kind == .both || kind == .movies {
			try modelContext.fetch(FetchDescriptor<Movie>()).forEach { genres.formUnion($0.genre) }
		}

		if kind == .both || kind == .tvShows {
			try modelContext.fetch(FetchDescriptor<TvShow>()).forEach { genres.formUnion($0.genre) }
		}

		return genres.sorted { $0.localizedStandardCompare($1) == .orderedAscending }
	}

	func items(inGenre genre: String, kind: GenreMediaKind, page: Int, perPage: Int) throws -> PagedResponse<MediaPreviewDTO> {
		var results: [MediaPreviewDTO] = []
		if kind == .both || kind == .movies {
			let movies = try modelContext.fetch(FetchDescriptor<Movie>())
				.filter { contains($0.genre, value: genre) }
			results.append(contentsOf: movies.map(\.previewDTO))
		}

		if kind == .both || kind == .tvShows {
			let tvShows = try modelContext.fetch(FetchDescriptor<TvShow>())
				.filter { contains($0.genre, value: genre) }
			results.append(contentsOf: tvShows.map(\.previewDTO))
		}

		results.sort { $0.name.localizedStandardCompare($1.name) == .orderedAscending }

		return paged(results, page: page, perPage: perPage)
	}

	func favorites(page: Int, perPage: Int) throws -> PagedResponse<MediaPreviewDTO> {
		var results = try modelContext.fetch(FetchDescriptor<Movie>()).filter(\.isFavorite).map(\.previewDTO)
		results += try modelContext.fetch(FetchDescriptor<TvShow>()).filter(\.isFavorite).map(\.previewDTO)
		results += try modelContext.fetch(FetchDescriptor<Episode>()).filter(\.isFavorite).map(\.previewDTO)

		return paged(sorted(results), page: page, perPage: perPage)
	}

	func pinned(page: Int, perPage: Int) throws -> PagedResponse<MediaPreviewDTO> {
		var results = try modelContext.fetch(FetchDescriptor<Movie>()).filter(\.isPinned).map(\.previewDTO)
		results += try modelContext.fetch(FetchDescriptor<TvShow>()).filter(\.isPinned).map(\.previewDTO)
		results += try modelContext.fetch(FetchDescriptor<Episode>()).filter(\.isPinned).map(\.previewDTO)
		results += try modelContext.fetch(FetchDescriptor<MediaCollection>()).filter(\.isPinned).map(\.previewDTO)

		return paged(sorted(results), page: page, perPage: perPage)
	}

	func unwatched(page: Int, perPage: Int) throws -> PagedResponse<MediaPreviewDTO> {
		var results = try modelContext.fetch(FetchDescriptor<Movie>()).filter { !$0.isWatched }.map(\.previewDTO)
		results += try modelContext.fetch(FetchDescriptor<TvShow>()).filter { !$0.isWatched }.map(\.previewDTO)
		results += try modelContext.fetch(FetchDescriptor<Episode>()).filter { !$0.isWatched }.map(\.previewDTO)

		return paged(sorted(results), page: page, perPage: perPage)
	}

	func artwork(id: UUID) throws -> Data? {
		if let value = try modelContext.fetch(FetchDescriptor<Movie>()).first(where: { $0.id == id })?.artwork { return value }
		if let value = try modelContext.fetch(FetchDescriptor<TvShow>()).first(where: { $0.id == id })?.artwork { return value }
		if let value = try modelContext.fetch(FetchDescriptor<Episode>()).first(where: { $0.id == id })?.artwork { return value }
		return try modelContext.fetch(FetchDescriptor<MediaCollection>()).first { $0.id == id }?.artwork
	}

	func videoFile(id: UUID) throws -> ResolvedVideoFile? {
		if let movie = try modelContext.fetch(FetchDescriptor<Movie>()).first(where: { $0.id == id }), let url = movie.url {
			return ResolvedVideoFile(url: url, title: movie.title)
		}

		if let episode = try modelContext.fetch(FetchDescriptor<Episode>()).first(where: { $0.id == id }), let url = episode.url {
			return ResolvedVideoFile(url: url, title: episode.title)
		}

		return nil
	}

	private func mediaItems(ids: [UUID]) throws -> [any MediaItem] {
		var seen: Set<UUID> = []
		let uniqueIDs = ids.filter { seen.insert($0).inserted }
		guard !uniqueIDs.isEmpty else { return [] }

		var itemsByID: [UUID: any MediaItem] = [:]
		try modelContext.fetch(FetchDescriptor<Movie>()).forEach { itemsByID[$0.id] = $0 }
		try modelContext.fetch(FetchDescriptor<TvShow>()).forEach { itemsByID[$0.id] = $0 }
		try modelContext.fetch(FetchDescriptor<Episode>()).forEach { itemsByID[$0.id] = $0 }

		let missingIDs = uniqueIDs.filter { itemsByID[$0] == nil }
		guard missingIDs.isEmpty else { throw MediaApiMutationError.mediaItemsNotFound(missingIDs) }
		return uniqueIDs.compactMap { itemsByID[$0] }
	}
}
