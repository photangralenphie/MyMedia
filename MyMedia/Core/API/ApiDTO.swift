//
// Copyright © 2026 MyMedia.
// Licensed under the MIT License.
//

import Foundation
import MyMediaAPI

extension Movie {
	public var DTO: ApiMovieDTO {
		ApiMovieDTO(
			id: id,
			dateAdded: dateAdded,
			isWatched: isWatched,
			isFavorite: isFavorite,
			isPinned: isPinned,
			progressMinutes: progressMinutes,
			artworkURL: artwork == nil ? nil : "/api/v1/artwork/\(id.uuidString)",
			title: title,
			year: year,
			genre: genre,
			durationMinutes: durationMinutes,
			releaseDate: releaseDate,
			shortDescription: shortDescription,
			longDescription: longDescription,
			credits: credits?.DTO ?? ApiCreditsDTO(),
			studio: studio,
			hdVideoQuality: hdVideoQuality?.title,
			rating: rating,
			languages: languages
		)
	}
}

extension TvShow {
	public var DTO: ApiTvShowDTO {
		let episodes = episodes.sorted {
			($0.season, $0.episode, $0.title) < ($1.season, $1.episode, $1.title)
		}

		return ApiTvShowDTO(
			id: id,
			dateAdded: dateAdded,
			title: title,
			year: year,
			genre: genre,
			showDescription: showDescription,
			artworkURL: artwork == nil ? nil : "/api/v1/artwork/\(id.uuidString)",
			isFavorite: isFavorite,
			isPinned: isPinned,
			isWatched: isWatched,
			networks: networks.sorted(),
			isMiniSeries: isMiniSeries,
			durationMinutes: episodes.reduce(0) { $0 + $1.durationMinutes },
			episodes: episodes.map(\.previewDTO)
		)
	}
}

extension Episode {
	public var DTO: ApiEpisodeDTO {
		ApiEpisodeDTO(
			id: id,
			dateAdded: dateAdded,
			isWatched: isWatched,
			isFavorite: isFavorite,
			isPinned: isPinned,
			progressMinutes: progressMinutes,
			artworkURL: artwork == nil ? nil : "/api/v1/artwork/\(id.uuidString)",
			season: season,
			episode: episode,
			title: title,
			year: year,
			durationMinutes: durationMinutes,
			releaseDate: releaseDate,
			episodeShortDescription: episodeShortDescription,
			episodeLongDescription: episodeLongDescription,
			credits: credits?.DTO ?? ApiCreditsDTO(),
			studio: studio,
			network: network,
			rating: rating,
			languages: languages,
			tvShow: tvShow.previewDTO
		)
	}
}

extension Person {
	public var DTO: ApiPersonDTO {
		ApiPersonDTO(
			name: name,
			roles: roles,
			creditedMovies: creditedMovies.map(\.previewDTO).sorted(by: previewTitleSort),
			creditedEpisodes: creditedEpisodes.map(\.previewDTO).sorted(by: previewTitleSort),
			credits: ApiPersonCreditsDTO(
				cast: creditPreviews(castCredits),
				directors: creditPreviews(directedCredits),
				coDirectors: creditPreviews(coDirectedCredits),
				screenwriters: creditPreviews(writtenCredits),
				producers: creditPreviews(producedCredits),
				executiveProducers: creditPreviews(executiveProducedCredits),
				composer: creditPreviews(composedCredits)
			)
		)
	}

	private func creditPreviews(_ credits: [Credits]) -> [MediaPreviewDTO] {
		var seen: Set<UUID> = []
		var items: [MediaPreviewDTO] = []

		for credit in credits {
			if let movie = credit.movie, seen.insert(movie.id).inserted {
				items.append(movie.previewDTO)
			}
			if let episode = credit.episode, seen.insert(episode.id).inserted {
				items.append(episode.previewDTO)
			}
		}

		return items.sorted(by: previewTitleSort)
	}
}

extension Credits {
	public var DTO: ApiCreditsDTO {
		ApiCreditsDTO(
			cast: cast.map(\.name).sorted(),
			directors: directors.map(\.name).sorted(),
			coDirectors: coDirectors.map(\.name).sorted(),
			screenwriters: screenwriters.map(\.name).sorted(),
			producers: producers.map(\.name).sorted(),
			executiveProducers: executiveProducers.map(\.name).sorted(),
			composer: composer?.name
		)
	}
}

extension MediaCollection {
	public var DTO: ApiMediaCollectionDTO {
		ApiMediaCollectionDTO(
			id: id,
			title: title,
			collectionDescription: collectionDescription,
			artworkURL: artwork == nil ? nil : "/api/v1/artwork/\(id.uuidString)",
			dateAdded: dateAdded,
			isPinned: isPinned,
			isWatched: isWatched,
			numberOfItems: mediaItems.count,
			items: mediaItems.map(\.previewDTO).sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
		)
	}

	public var previewDTO: MediaPreviewDTO {
		MediaPreviewDTO(
			kind: .collection,
			id: id,
			name: title,
			year: nil,
			season: nil,
			episode: nil,
			numberOfItems: mediaItems.count,
			previewArtworkURL: artwork == nil ? nil : "/api/v1/artwork/\(id.uuidString)?maxSize=\(ApiConfiguration.previewArtworkSize)"
		)
	}
}

extension MediaItem {
	public var previewDTO: MediaPreviewDTO {
		switch self {
			case let movie as Movie: preview(kind: .movie, id: id, name: title, year: year, artwork: artwork)
			case let tvShow as TvShow: preview(kind: .tvShow, id: id, name: title, year: year, artwork: artwork)
			case let episode as Episode: preview(kind: .episode, id: id, name: episode.title, year: episode.year, season: episode.season, episode: episode.episode, artwork: episode.artwork)
			default: preconditionFailure("Unsupported media model")
		}
	}

	private func preview(kind: ApiMediaKind, id: UUID, name: String, year: Int? = nil, season: Int? = nil, episode: Int? = nil, numberOfItems: Int? = nil, artwork: Data?) -> MediaPreviewDTO {
		MediaPreviewDTO(
			kind: kind,
			id: id,
			name: name,
			year: year,
			season: season,
			episode: episode,
			numberOfItems: numberOfItems,
			previewArtworkURL: artwork == nil ? nil : "/api/v1/artwork/\(id.uuidString)?maxSize=\(ApiConfiguration.previewArtworkSize)"
		)
	}
}
