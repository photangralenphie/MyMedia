//
// Copyright © 2026 MyMedia.
// Licensed under the MIT License.
//

import Foundation

/// Supplies value-only media data to the HTTP server.
@MainActor
public protocol MediaApiRepository: AnyObject, Sendable {
	func appearance() -> ApiAppearanceDTO
	func movies(filters: ApiListFilters, page: Int, perPage: Int) throws -> PagedResponse<MediaPreviewDTO>
	func movie(id: UUID) throws -> ApiMovieDTO?
	func updateMovie(id: UUID, with update: ApiMediaItemUpdateRequest) throws -> ApiMovieDTO?
	func tvShows(filters: ApiListFilters, page: Int, perPage: Int) throws -> PagedResponse<MediaPreviewDTO>
	func tvShow(id: UUID) throws -> ApiTvShowDTO?
	func updateTvShow(id: UUID, with update: ApiMediaItemUpdateRequest) throws -> ApiTvShowDTO?
	func episode(id: UUID) throws -> ApiEpisodeDTO?
	func updateEpisode(id: UUID, with update: ApiMediaItemUpdateRequest) throws -> ApiEpisodeDTO?
	func person(name: String) throws -> ApiPersonDTO?
	func collections(page: Int, perPage: Int) throws -> PagedResponse<MediaPreviewDTO>
	func collection(id: UUID) throws -> ApiMediaCollectionDTO?
	func createCollection(from request: ApiCreateMediaCollectionRequest) throws -> ApiMediaCollectionDTO
	func updateCollection(id: UUID, with update: ApiMediaCollectionUpdateRequest) throws -> ApiMediaCollectionDTO?
	func search(query: String, scope: ApiSearchScope, page: Int, perPage: Int) throws -> PagedResponse<MediaPreviewDTO>
	func genres(kind: GenreMediaKind) throws -> [String]
	func items(inGenre genre: String, kind: GenreMediaKind, page: Int, perPage: Int) throws -> PagedResponse<MediaPreviewDTO>
	func favorites(page: Int, perPage: Int) throws -> PagedResponse<MediaPreviewDTO>
	func pinned(page: Int, perPage: Int) throws -> PagedResponse<MediaPreviewDTO>
	func unwatched(page: Int, perPage: Int) throws -> PagedResponse<MediaPreviewDTO>
	func artwork(id: UUID) throws -> Data?
	func videoFile(id: UUID) throws -> ResolvedVideoFile?
}
