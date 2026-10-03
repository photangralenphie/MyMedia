//
// Copyright © 2026 MyMedia.
// Licensed under the MIT License.
//

import MyMediaAPI

struct FilterValues {
	let year: Int
	let length: Int
	let isFavorite: Bool
	let isWatched: Bool
	let genres: [String]
}

func matchesCommonFilters(_ values: FilterValues, filters: ApiListFilters) -> Bool {
	if let filter = filters.year, !filter.contains(values.year) { return false }
	if let filter = filters.minimumLength, values.length < filter { return false }
	if let filter = filters.maximumLength, values.length > filter { return false }
	if let filter = filters.isFavorite, values.isFavorite != filter { return false }
	if let filter = filters.isWatched, values.isWatched != filter { return false }

	if !filters.genre.isEmpty,
	   !filters.genre.contains(where: { contains(values.genres, value: $0) }) {
		return false
	}

	return true
}

func matchesSearch(movie: Movie, query: String, scope: ApiSearchScope) -> Bool {
	(scope == .all || scope == .title) && matches(movie.title, query: query)
	|| (scope == .all || scope == .description) && [movie.shortDescription, movie.longDescription].compactMap(\.self).contains { matches($0, query: query) }
	|| (scope == .all || scope == .credits) && matches(movie.credits, query: query)
}

func matchesSearch(tvShow: TvShow, query: String, scope: ApiSearchScope) -> Bool {
	(scope == .all || scope == .title) && matches(tvShow.title, query: query)
	|| (scope == .all || scope == .description) && tvShow.showDescription.map { matches($0, query: query) } == true
}

func matchesSearch(episode: Episode, query: String, scope: ApiSearchScope) -> Bool {
	(scope == .all || scope == .title) && matches(episode.title, query: query)
	|| (scope == .all || scope == .description) && [episode.episodeShortDescription, episode.episodeLongDescription].compactMap(\.self).contains { matches($0, query: query) }
	|| (scope == .all || scope == .credits) && matches(episode.credits, query: query)
}

func matches(_ credits: Credits?, query: String) -> Bool {
	guard let credits else { return false }
	return credits.people.contains { matches($0.name, query: query) }
}

func matches(_ text: String, query: String) -> Bool {
	text.range(of: query, options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive]) != nil
}

func contains(_ values: [String], value: String) -> Bool {
	values.contains { $0.compare(value, options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive]) == .orderedSame }
}

func previewTitleSort(_ lhs: MediaPreviewDTO, _ rhs: MediaPreviewDTO) -> Bool {
	lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
}

func titleSort<T: MediaItem>(_ lhs: T, _ rhs: T) -> Bool {
	lhs.title.localizedStandardCompare(rhs.title) == .orderedAscending
}

func titleSort(_ lhs: MediaCollection, _ rhs: MediaCollection) -> Bool {
	lhs.title.localizedStandardCompare(rhs.title) == .orderedAscending
}

func sorted(_ items: [MediaPreviewDTO]) -> [MediaPreviewDTO] {
	items.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
}

func paged<T: Codable & Sendable>(_ items: [T], page: Int, perPage: Int) -> PagedResponse<T> {
	let offset = (page - 1) * perPage
	let pageItems = offset < items.count ? Array(items.dropFirst(offset).prefix(perPage)) : []

	return PagedResponse(items: pageItems, page: page, perPage: perPage, totalItems: items.count)
}
