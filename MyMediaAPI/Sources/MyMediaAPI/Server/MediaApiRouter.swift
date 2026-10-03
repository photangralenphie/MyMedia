//
// Copyright © 2026 MyMedia.
// Licensed under the MIT License.
//

import Foundation
import Hummingbird

internal struct MediaApiRouter {
	static func make(repository: any MediaApiRepository) -> Router<BasicRequestContext> {
		let router = Router(context: BasicRequestContext.self)
		router.middlewares.add(
			CORSMiddleware(
				allowOrigin: .all,
				allowMethods: [.get, .post, .patch, .head, .options],
				exposedHeaders: ["Content-Range", "Accept-Ranges", "Content-Disposition"]
			)
		)

		if let documentationDirectory = ApiDocumentation.documentationDirectory {
			router.middlewares.add(
				FileMiddleware(
					documentationDirectory.path,
					urlBasePath: "/docs",
					searchForIndexHtml: true
				)
			)
		}

		registerGeneralRoutes(on: router, repository: repository)
		registerLibraryRoutes(on: router, repository: repository)
		registerDiscoveryRoutes(on: router, repository: repository)
		registerAssetRoutes(on: router, repository: repository)
		registerDocumentationRoutes(on: router)

		return router
	}

	private static func registerGeneralRoutes(on router: Router<BasicRequestContext>, repository: any MediaApiRepository) {
		router.get("/") { _, _ in Response.redirect(to: ApiDocumentation.landingPath, type: .temporary) }
		router.get("/api/v1/health") { _, _ in try ApiResponse.json(["status": "ok"]) }
		router.get("/api/v1/appearance") { _, _ in
			try await ApiResponse.json(repository.appearance())
		}
	}

	private static func registerLibraryRoutes(on router: Router<BasicRequestContext>, repository: any MediaApiRepository) {
		registerMovieRoutes(on: router, repository: repository)
		registerTvShowRoutes(on: router, repository: repository)
		registerEpisodeRoutes(on: router, repository: repository)
		registerPeopleRoutes(on: router, repository: repository)
		registerCollectionRoutes(on: router, repository: repository)
	}

	private static func registerMovieRoutes(on router: Router<BasicRequestContext>, repository: any MediaApiRepository) {
		router.get("/api/v1/movies") { request, _ in
			let pagination = try ApiQueryParser.pagination(from: request)
			let filters = try ApiQueryParser.filters(from: request)
			let movies = try await repository.movies(filters: filters, page: pagination.page, perPage: pagination.perPage)
			return try ApiResponse.json(movies)
		}

		router.get("/api/v1/movies/:id") { _, context in
			let id = try context.parameters.require("id", as: UUID.self)
			guard let movie = try await repository.movie(id: id) else { throw HTTPError(.notFound) }
			return try ApiResponse.json(movie)
		}

		router.patch("/api/v1/movies/:id") { request, context in
			let id = try context.parameters.require("id", as: UUID.self)
			let update = try await request.decode(as: ApiMediaItemUpdateRequest.self, context: context)
			try validateMediaItemUpdate(update)

			do {
				guard let movie = try await repository.updateMovie(id: id, with: update) else { throw HTTPError(.notFound) }
				return try ApiResponse.json(movie)
			} catch let error as MediaApiMutationError {
				throw httpError(for: error)
			}
		}
	}

	private static func registerTvShowRoutes(on router: Router<BasicRequestContext>, repository: any MediaApiRepository) {
		router.get("/api/v1/tv-shows") { request, _ in
			let pagination = try ApiQueryParser.pagination(from: request)
			let filters = try ApiQueryParser.filters(from: request)
			let shows = try await repository.tvShows(filters: filters, page: pagination.page, perPage: pagination.perPage)

			return try ApiResponse.json(shows)
		}

		router.get("/api/v1/tv-shows/:id") { _, context in
			let id = try context.parameters.require("id", as: UUID.self)
			guard let tvShow = try await repository.tvShow(id: id) else { throw HTTPError(.notFound) }

			return try ApiResponse.json(tvShow)
		}

		router.patch("/api/v1/tv-shows/:id") { request, context in
			let id = try context.parameters.require("id", as: UUID.self)
			let update = try await request.decode(as: ApiMediaItemUpdateRequest.self, context: context)
			try validateMediaItemUpdate(update, supportsProgress: false)
			guard let tvShow = try await repository.updateTvShow(id: id, with: update) else { throw HTTPError(.notFound) }

			return try ApiResponse.json(tvShow)
		}
	}

	private static func registerEpisodeRoutes(on router: Router<BasicRequestContext>, repository: any MediaApiRepository) {
		router.get("/api/v1/episodes/:id") { _, context in
			let id = try context.parameters.require("id", as: UUID.self)
			guard let episode = try await repository.episode(id: id) else { throw HTTPError(.notFound) }

			return try ApiResponse.json(episode)
		}

		router.patch("/api/v1/episodes/:id") { request, context in
			let id = try context.parameters.require("id", as: UUID.self)
			let update = try await request.decode(as: ApiMediaItemUpdateRequest.self, context: context)
			try validateMediaItemUpdate(update)

			do {
				guard let episode = try await repository.updateEpisode(id: id, with: update) else { throw HTTPError(.notFound) }
				return try ApiResponse.json(episode)
			} catch let error as MediaApiMutationError {
				throw httpError(for: error)
			}
		}
	}

	private static func registerPeopleRoutes(on router: Router<BasicRequestContext>, repository: any MediaApiRepository) {
		router.get("/api/v1/people/:name") { _, context in
			let encodedName: String = try context.parameters.require("name")
			guard let name = encodedName.removingPercentEncoding, !name.isEmpty else {
				throw HTTPError(.badRequest, message: "The person name is not valid URL encoding.")
			}
			guard let person = try await repository.person(name: name) else { throw HTTPError(.notFound) }

			return try ApiResponse.json(person)
		}
	}

	private static func registerCollectionRoutes(on router: Router<BasicRequestContext>, repository: any MediaApiRepository) {
		router.get("/api/v1/collections") { request, _ in
			let pagination = try ApiQueryParser.pagination(from: request)
			let collections = try await repository.collections(page: pagination.page, perPage: pagination.perPage)

			return try ApiResponse.json(collections)
		}

		router.post("/api/v1/collections") { request, context in
			let creation = try await request.decode(as: ApiCreateMediaCollectionRequest.self, context: context)
			guard !creation.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
				throw HTTPError(.badRequest, message: "Collection title cannot be empty.")
			}

			do {
				let collection = try await repository.createCollection(from: creation)
				return try ApiResponse.json(collection, status: .created)
			} catch let error as MediaApiMutationError {
				throw httpError(for: error)
			}
		}

		router.get("/api/v1/collections/:id") { _, context in
			let id = try context.parameters.require("id", as: UUID.self)
			guard let collection = try await repository.collection(id: id) else { throw HTTPError(.notFound) }
			return try ApiResponse.json(collection)
		}

		router.patch("/api/v1/collections/:id") { request, context in
			let id = try context.parameters.require("id", as: UUID.self)
			let update = try await request.decode(as: ApiMediaCollectionUpdateRequest.self, context: context)
			let additions = Set(update.add ?? [])
			let removals = Set(update.remove ?? [])

			guard !additions.isEmpty || !removals.isEmpty || update.isPinned != nil else {
				throw HTTPError(.badRequest, message: "At least one media item change or isPinned must be supplied.")
			}

			guard additions.isDisjoint(with: removals) else {
				throw HTTPError(.badRequest, message: "A media item cannot be added and removed in the same request.")
			}

			do {
				guard let collection = try await repository.updateCollection(id: id, with: update) else { throw HTTPError(.notFound) }
				return try ApiResponse.json(collection)
			} catch let error as MediaApiMutationError {
				throw httpError(for: error)
			}
		}
	}

	private static func validateMediaItemUpdate(_ update: ApiMediaItemUpdateRequest, supportsProgress: Bool = true) throws {
		guard update.isWatched != nil || update.isFavorite != nil || update.isPinned != nil || update.progressMinutes != nil else {
			throw HTTPError(.badRequest, message: "At least one supported field must be supplied.")
		}

		if !supportsProgress, update.progressMinutes != nil {
			throw HTTPError(.badRequest, message: "progressMinutes does not apply to TV shows.")
		}

		if let progressMinutes = update.progressMinutes, progressMinutes < 0 {
			throw HTTPError(.badRequest, message: "progressMinutes cannot be negative.")
		}
	}

	private static func httpError(for error: MediaApiMutationError) -> HTTPError {
		switch error {
			case .mediaItemsNotFound(let ids):
				let joinedIDs = ids.map(\.uuidString).joined(separator: ", ")
				return HTTPError(.notFound, message: "Media items not found: \(joinedIDs).")
			case .progressExceedsDuration(let durationMinutes):
				return HTTPError(.badRequest, message: "progressMinutes cannot exceed the duration of \(durationMinutes) minutes.")
		}
	}

	private static func registerDiscoveryRoutes(on router: Router<BasicRequestContext>, repository: any MediaApiRepository) {
		router.get("/api/v1/search") { request, _ in
			let pagination = try ApiQueryParser.pagination(from: request)
			guard let rawQuery = request.uri.queryParameters["query"] else {
				throw HTTPError(.badRequest, message: "Missing required query parameter 'query'.")
			}

			let scope = try ApiQueryParser.enumValue(request, name: "scope", default: ApiSearchScope.all)
			let results = try await repository.search(
				query: String(rawQuery),
				scope: scope,
				page: pagination.page,
				perPage: pagination.perPage
			)

			return try ApiResponse.json(results)
		}

		router.get("/api/v1/genres") { request, _ in
			let kind = try ApiQueryParser.enumValue(request, name: "kind", default: GenreMediaKind.both)

			return try await ApiResponse.json(repository.genres(kind: kind))
		}

		router.get("/api/v1/genres/:genre") { request, context in
			let pagination = try ApiQueryParser.pagination(from: request)
			let genre = try context.parameters.require("genre")
			let kind = try ApiQueryParser.enumValue(request, name: "kind", default: GenreMediaKind.both)
			let items = try await repository.items(inGenre: genre, kind: kind, page: pagination.page, perPage: pagination.perPage)

			return try ApiResponse.json(items)
		}

		registerFeedRoute("/api/v1/favorites", on: router, load: repository.favorites)
		registerFeedRoute("/api/v1/pinned", on: router, load: repository.pinned)
		registerFeedRoute("/api/v1/unwatched", on: router, load: repository.unwatched)
	}

	private static func registerFeedRoute(_ path: RouterPath, on router: Router<BasicRequestContext>, load: @escaping @MainActor (Int, Int) throws -> PagedResponse<MediaPreviewDTO>) {
		router.get(path) { request, _ in
			let pagination = try ApiQueryParser.pagination(from: request)
			let items = try await load(pagination.page, pagination.perPage)

			return try ApiResponse.json(items)
		}
	}

	private static func registerAssetRoutes(on router: Router<BasicRequestContext>, repository: any MediaApiRepository) {
		router.get("/api/v1/artwork/:id") { request, context in
			let id = try context.parameters.require("id", as: UUID.self)
			let maximumSize = try ApiQueryParser.artworkMaximumSize(from: request)

			guard let original = try await repository.artwork(id: id) else { throw HTTPError(.notFound) }
			guard let maximumSize else {
				let artwork = ArtworkService.fullArtwork(from: original)
				return ApiResponse.data(artwork.data, contentType: artwork.mimeType, cacheControl: "private, max-age=3600")
			}

			guard let artwork = ArtworkService.resized(from: original, maximumPixels: maximumSize) else {
				throw HTTPError(.internalServerError, message: "The artwork could not be decoded.")
			}

			return ApiResponse.data(artwork.data, contentType: artwork.mimeType, cacheControl: "private, max-age=3600")
		}

		router.get("/api/v1/videos/:id") { request, context in
			let id = try context.parameters.require("id", as: UUID.self)
			guard let file = try await repository.videoFile(id: id) else { throw HTTPError(.notFound) }

			return try VideoStreamer.response(for: file, request: request, includeBody: true)
		}

		router.head("/api/v1/videos/:id") { request, context in
			let id = try context.parameters.require("id", as: UUID.self)
			guard let file = try await repository.videoFile(id: id) else { throw HTTPError(.notFound) }

			return try VideoStreamer.response(for: file, request: request, includeBody: false)
		}

		router.get("/api/v1/videos/:id/download") { request, context in
			let id = try context.parameters.require("id", as: UUID.self)
			guard let file = try await repository.videoFile(id: id) else { throw HTTPError(.notFound) }

			return try VideoStreamer.response(for: file, request: request, includeBody: true, disposition: .attachment)
		}
	}

	private static func registerDocumentationRoutes(on router: Router<BasicRequestContext>) {
		router.get("/docs") { _, _ in
			Response.redirect(to: ApiDocumentation.landingPath, type: .temporary)
		}

		router.get("/openapi.yaml") { _, _ in
			guard let specification = ApiDocumentation.openAPISpecification else { throw HTTPError(.notFound) }
			return ApiResponse.yaml(specification)
		}

		router.get("/api-docs") { _, _ in
			guard let html = ApiDocumentation.scalarDocs else { throw HTTPError(.notFound) }
			return ApiResponse.html(html)
		}
	}

	private init() {}
}
