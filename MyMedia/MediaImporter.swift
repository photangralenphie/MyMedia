//
//  MediaImporter.swift
//  MyMedia
//
//  Created by Jonas Helmer on 30.03.25.
//

import SwiftUI
import SwiftData
import MP42Foundation

enum ImportError: LocalizedError {
	case fileNotAccessible
	case missingMetadata(type: String)
	case unknown(message: String)

	var errorDescription: String? {
		switch self {
			case .fileNotAccessible: return "Could not access file."
			case .missingMetadata(let type): return metadataError(metadataType: type)
			case .unknown(let message): return "Unknown Error while reading file: \(message)."
		}
	}
	
	private func metadataError(metadataType: String) -> String {
		return "No \(metadataType) found in metadata."
	}
}


class MediaImporter {
	
	public static func importFile(data: URL, moc: ModelContext, existingTvShows: [TvShow]) throws {
		let file = try? getMP4V2File(url: data)
		
		guard let file = file else { return }
		let kind = file.metadata.metadataItemsFiltered(byIdentifier: MP42MetadataKeyMediaKind).first
		if(kind?.dataType == MP42MetadataItemDataType.integer && kind?.numberValue == 10){
			try readTvMetadata(file: file, moc: moc, existingTvShows: existingTvShows)
		}
	}
	
	private static func readTvMetadata(file: MP42File, moc: ModelContext, existingTvShows: [TvShow]) throws {
		let showTitle = try file.getStringMetaDataValue(for: MP42MetadataKeyTVShow)
		
		var show = existingTvShows.filter { $0.title == showTitle }.first
		
		
		if show == nil {
			show = try createTvShowFromEpisode(file: file)
			moc.insert(show!)
		}
		
		guard let show = show else {
			throw ImportError.unknown(message: "Something went wrong creating a TV show from file \(file.url!)")
		}
		
		let episode = try createEpisodeFromFile(file: file)
		show.episodes.append(episode)
		try moc.save()
	}
	
	public static func getMP4V2File(url: URL) throws -> MP42File  {
		if url.startAccessingSecurityScopedResource() {
			let file = try MP42File(url: url)
			url.stopAccessingSecurityScopedResource()
			return file
		} else {
			throw ImportError.fileNotAccessible
		}
	}

	public static func createTvShowFromEpisode(file: MP42File) throws -> TvShow {
		let title = try file.getStringMetaDataValue(for: MP42MetadataKeyTVShow)
		let date = try file.getDateMetaDataValue(for: MP42MetadataKeyReleaseDate)
		let year = Calendar.current.component(.year, from: date)
		let genre = file.tryGetStringMetaDataValue(for: MP42MetadataKeyUserGenre)
		let seriesDescription = file.tryGetStringMetaDataValue(for: MP42MetadataKeySeriesDescription)
		let artwork = file.tryGetImageMetaDataValue(for: MP42MetadataKeyCoverArt)
		
		return TvShow(title: title, year: year, genre: genre, showDescription: seriesDescription, artwork: artwork)
	}
	
	public static func createEpisodeFromFile(file: MP42File) throws -> Episode {
		let artwork = file.tryGetImageMetaDataValue(for: MP42MetadataKeyCoverArt)
		let seasonNumber = try file.getIntMetaDataValue(for: MP42MetadataKeyTVSeason)
		let episodeNumber = try file.getIntMetaDataValue(for: MP42MetadataKeyTVEpisodeNumber)
		let title = try file.getStringMetaDataValue(for: MP42MetadataKeyName)
		let runtime = Int(file.duration) / 60000
		let releaseDate = try file.getDateMetaDataValue(for: MP42MetadataKeyReleaseDate)
		let shortDescription = file.tryGetStringMetaDataValue(for: MP42MetadataKeyDescription)
		let longDescription = file.tryGetStringMetaDataValue(for: MP42MetadataKeyLongDescription)
		let producers = file.tryGetStringArrayMetaDataValue(for: MP42MetadataKeyProducer)
		let cast = file.tryGetStringArrayMetaDataValue(for: MP42MetadataKeyCast)
		let directors = file.tryGetStringArrayMetaDataValue(for: MP42MetadataKeyDirector)
		let screenwriters = file.tryGetStringArrayMetaDataValue(for: MP42MetadataKeyScreenwriters)
		let studio = file.tryGetStringMetaDataValue(for: MP42MetadataKeyStudio)
		let network = file.tryGetStringMetaDataValue(for: MP42MetadataKeyTVNetwork)
		let rating = file.tryGetStringMetaDataValue(for: MP42MetadataKeyRating)
		let languages = file.tracks.filter { $0.mediaType == kMP42MediaType_Audio }.map(\.language)
		
		if file.url == nil {
			throw ImportError.missingMetadata(type: "URL")
		}
		
		let url = file.url!
		
		let episode = Episode(artwork: artwork, season: seasonNumber, episode: episodeNumber, title: title, runtime: runtime, releaseDate: releaseDate, episodeShortDescription: shortDescription, episodeLongDescription: longDescription, cast: cast, producers: producers, directors: directors, screenwriters: screenwriters, studio: studio, network: network, rating: rating, languages: languages, url: url)
		
		return episode
	}
}

extension MP42File {
	
	// String
	func getStringMetaDataValue(for key: String) throws -> String {
		if let stringValue = self.tryGetStringMetaDataValue(for: key) {
			return stringValue
		}
		throw ImportError.missingMetadata(type: key)
	}

	func tryGetStringMetaDataValue(for key: String) -> String? {
		return self.metadata.metadataItemsFiltered(byIdentifier: key).first?.stringValue
	}
	
	// Int
	func getIntMetaDataValue(for key: String) throws -> Int {
		if let intValue = self.tryGetIntMetaDataValue(for: key) {
			return intValue
		}
		throw ImportError.missingMetadata(type: key)
	}
	
	func tryGetIntMetaDataValue(for key: String) -> Int? {
		return self.metadata.metadataItemsFiltered(byIdentifier: key).first?.numberValue?.intValue
	}

	// String Array
	func getStringArrayMetaDataValue(for key: String) throws -> [String] {
		if let stringArrayValue = self.tryGetStringArrayMetaDataValue(for: key) {
			return stringArrayValue
		}
		throw ImportError.missingMetadata(type: key)
	}

	func tryGetStringArrayMetaDataValue(for key: String) -> [String]? {
		return self.metadata.metadataItemsFiltered(byIdentifier: key).first?.arrayValue?.compactMap { $0 as? String }
	}
	
	// Date
	func getDateMetaDataValue(for key: String) throws -> Date {
		if let date = self.tryGetDateMetaDataValue(for: key) {
			return date
		}
		throw ImportError.missingMetadata(type: key)
	}
	
	func tryGetDateMetaDataValue(for key: String) -> Date? {
		return self.metadata.metadataItemsFiltered(byIdentifier: key).first?.dateValue
	}
	
	
	// Artwork
	func tryGetImageMetaDataValue(for key: String) -> Data? {
		return self.metadata.metadataItemsFiltered(byIdentifier: key).first?.imageValue?.data
	}
}
