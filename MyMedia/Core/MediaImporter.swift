//
//  MediaImporter.swift
//  MyMedia
//
//  Created by Jonas Helmer on 30.03.25.
//

import SwiftUI
import SwiftData
import AVFoundation

enum ImportError: LocalizedError {
	case fileNotAccessible
	case noMetadataFound
	case missingMetadata(type: String)
	case unknown(message: String)

	var errorDescription: String? {
		switch self {
			case .fileNotAccessible: return "Could not access file."
			case .missingMetadata(let type): return metadataError(metadataType: type)
			case .unknown(let message): return "Unknown Error while reading file: \(message)."
			case .noMetadataFound: return "No metadata found in file. Please add metadata before importing."
		}
	}
	
	private func metadataError(metadataType: String) -> String {
		return "No \(metadataType) found in metadata."
	}
}

enum HDVideoQuality: Int, Codable {
	case sd = 0
	case hd720p = 1
	case hd1080p = 2
	case uhd4k = 3
	
	var badgeTitle: String {
		switch self {
			case .sd: return "SD"
			case .hd720p: return "Standard HD"
			case .hd1080p: return "Full HD"
			case .uhd4k: return "4K"
		}
	}
}


class MediaImporter {
	
	let context: ModelContext
	
	init(container: ModelContainer) {
		self.context = ModelContext(container)
	}
	
	public func importFromFile(path: URL) async throws {
		if !path.startAccessingSecurityScopedResource() {
			throw ImportError.fileNotAccessible
		}
		
		let asset = AVURLAsset(url: path)
		let metadata = try await asset.load(.metadata)
		
		let kind = await metadata.tryGetIntMetaDataValue(for: "itsk/stik")
		
		if kind == nil  {
			throw ImportError.noMetadataFound
		}
		
		if(kind == 9){
			 try await readMovieMetadata(metadata: metadata, asset: asset)
		}
	
		if(kind == 10) {
			try await readTvMetadata(metaData: metadata, asset: asset, source: path)
		}
		
		path.stopAccessingSecurityScopedResource()
	}
	
	public func importFromFiles(paths: [URL]) async throws {
		for path in paths {
			try await self.importFromFile(path: path)
		}
	}
	
	private func readTvMetadata(metaData: [AVMetadataItem], asset: AVURLAsset, source: URL) async throws {
		let showTitle = try await metaData.getStringMetaDataValue(for: .commonIdentifierArtist)
		
		let existingTvShows = try await fetchCurrentTvShows()
		var show = existingTvShows.filter { $0.title == showTitle }.first
		
		if show == nil {
			show = try await createTvShowFromEpisode(metadata: metaData)
			context.insert(show!)
		}
		
		guard let show = show else {
			throw ImportError.unknown(message: "Something went wrong creating a TV show from file \(source)")
		}
		
		let episode = try await createEpisodeFromFile(metadata: metaData, asset: asset)
		show.episodes.append(episode)
		
		try context.save()
	}
	
	private func readMovieMetadata(metadata: [AVMetadataItem], asset: AVURLAsset) async throws {
		let movie = try await createMovieFromFile(metadata: metadata, asset: asset)
		context.insert(movie)
		try context.save()
	}
	
	private func createMovieFromFile(metadata: [AVMetadataItem], asset: AVURLAsset) async throws -> Movie {
		let artwork = await metadata.tryGetImageMetaDataValue(artworkType: .moviePoster)
		let title = try await metadata.getStringMetaDataValue(for: .commonIdentifierTitle)
		let genre = try await metadata.getGenres()
		let durationMinutes = try await asset.getRuntimeMinutes()
		let releaseDate = try await metadata.getDateMetaDataValue(for: .iTunesMetadataReleaseDate)
		let shortDescription = await metadata.tryGetStringMetaDataValue(for: "itsk/desc")
		let longDescription = await metadata.tryGetStringMetaDataValue(for: "itsk/ldes")
		let producers = await metadata.tryGetStringArrayMetaDataValue(for: "itlk/com.apple.iTunes.iTunMOVI", creditCroup: "producers") ?? []
		let executiveProducers = (await metadata.tryGetStringMetaDataValue(for: "itsk/%A9xpd") ?? "").split(separator: ", ").map { String($0) }
		let cast = await metadata.tryGetStringArrayMetaDataValue(for: "itlk/com.apple.iTunes.iTunMOVI", creditCroup: "cast") ?? []
		let directors = await metadata.tryGetStringArrayMetaDataValue(for: "itlk/com.apple.iTunes.iTunMOVI", creditCroup: "directors") ?? []
		let coDirectors = await metadata.tryGetStringArrayMetaDataValue(for: "itlk/com.apple.iTunes.iTunMOVI", creditCroup: "codirectors") ?? []
		let screenwriters = await metadata.tryGetStringArrayMetaDataValue(for: "itlk/com.apple.iTunes.iTunMOVI", creditCroup: "screenwriters") ?? []
		let composer = await metadata.tryGetStringMetaDataValue(for: .iTunesMetadataComposer)
		let studio = await metadata.tryGetStringArrayMetaDataValue(for: "itlk/com.apple.iTunes.iTunMOVI", creditCroup: "studio")?.first
		let rating = await metadata.tryGetStringMetaDataValue(for: "itlk/com.apple.iTunes.iTunEXTC")
		let languages = try await asset.getAudioLanguages()
		let resolution = try await metadata.getResolution()
		let url = asset.url
		
		var movie = Movie(
			artwork: artwork,
			title: title,
			genre: genre,
			durationMinutes: durationMinutes,
			releaseDate: releaseDate,
			shortDescription: shortDescription,
			longDescription: longDescription,
			cast: cast,
			producers: producers,
			executiveProducers: executiveProducers,
			directors: directors,
			coDirectors: coDirectors,
			screenwriters: screenwriters,
			composer: composer,
			studio: studio,
			hdVideoQuality: resolution,
			rating: rating,
			languages: languages,
		)
		
		movie.url = url
		return movie
	}
	
	private func createTvShowFromEpisode(metadata: [AVMetadataItem]) async throws -> TvShow {
		let title = try await metadata.getStringMetaDataValue(for: .commonIdentifierArtist)
		let date = try await metadata.getDateMetaDataValue(for: .iTunesMetadataReleaseDate)
		let year = Calendar.current.component(.year, from: date)
		let genre = try await metadata.getGenres()
		let seriesDescription = await metadata.tryGetStringMetaDataValue(for: "itsk/sdes")
		let artwork = await metadata.tryGetImageMetaDataValue(artworkType: .tvPoster)
		
		return TvShow(
			title: title,
			year: year,
			genre: genre,
			showDescription: seriesDescription,
			artwork: artwork
		)
	}
	
	private func createEpisodeFromFile(metadata: [AVMetadataItem], asset: AVURLAsset) async throws -> Episode {
		let artwork = await metadata.tryGetImageMetaDataValue(artworkType: .episodeImage)
		let seasonNumber = try await metadata.getIntMetaDataValue(for: "itsk/tvsn")
		let episodeNumber = try await metadata.getIntMetaDataValue(for: "itsk/tves")
		let title = try await metadata.getStringMetaDataValue(for: .commonIdentifierTitle)
		let durationMinutes = try await asset.getRuntimeMinutes()
		let releaseDate = try await metadata.getDateMetaDataValue(for: .iTunesMetadataReleaseDate)
		let shortDescription = await metadata.tryGetStringMetaDataValue(for: "itsk/desc")
		let longDescription = await metadata.tryGetStringMetaDataValue(for: "itsk/ldes")
		let producers = await metadata.tryGetStringArrayMetaDataValue(for: "itlk/com.apple.iTunes.iTunMOVI", creditCroup: "producers") ?? []
		let executiveProducers = (await metadata.tryGetStringMetaDataValue(for: "itsk/%A9xpd") ?? "").split(separator: ", ").map { String($0) }
		let cast = await metadata.tryGetStringArrayMetaDataValue(for: "itlk/com.apple.iTunes.iTunMOVI", creditCroup: "cast") ?? []
		let directors = await metadata.tryGetStringArrayMetaDataValue(for: "itlk/com.apple.iTunes.iTunMOVI", creditCroup: "directors") ?? []
		let coDirectors = await metadata.tryGetStringArrayMetaDataValue(for: "itlk/com.apple.iTunes.iTunMOVI", creditCroup: "codirectors") ?? []
		let screenwriters = await metadata.tryGetStringArrayMetaDataValue(for: "itlk/com.apple.iTunes.iTunMOVI", creditCroup: "screenwriters") ?? []
		let composer = await metadata.tryGetStringMetaDataValue(for: .iTunesMetadataComposer)
		let studio = await metadata.tryGetStringArrayMetaDataValue(for: "itlk/com.apple.iTunes.iTunMOVI", creditCroup: "studio")?.first
		let network = await metadata.tryGetStringMetaDataValue(for: "itsk/tvnn")
		let rating = await metadata.tryGetStringMetaDataValue(for: "itlk/com.apple.iTunes.iTunEXTC")
		let languages = try await asset.getAudioLanguages()
		let url = asset.url
		
		var episode = Episode(
			artwork: artwork,
			season: seasonNumber,
			episode: episodeNumber,
			title: title,
			durationMinutes: durationMinutes,
			releaseDate: releaseDate,
			episodeShortDescription: shortDescription,
			episodeLongDescription: longDescription,
			cast: cast,
			producers: producers,
			executiveProducers: executiveProducers,
			directors: directors,
			coDirectors: coDirectors,
			screenwriters: screenwriters,
			composer: composer,
			studio: studio,
			network: network,
			rating: rating,
			languages: languages,
		)
		
		episode.url = url
		return episode
	}
	
	private func fetchCurrentTvShows() async throws -> [TvShow] {
		let descriptor = FetchDescriptor<TvShow>()
		return try context.fetch(descriptor)
	}
}

enum ArtworkType {
	case moviePoster
	case tvPoster
	case episodeImage
	
	var index: Int {
		switch self {
			case .moviePoster:
				return 0
			case .tvPoster:
				return 0
			case .episodeImage:
				return 1
		}
	}
}

extension AVURLAsset {
	func getAudioLanguages() async throws -> [String] {
		let tracks = try await self.loadTracks(withMediaType: .audio)
		var languages: [String] = []
		
		for track in tracks {
			if let code = try await track.load(.languageCode) {
				languages.append(code)
			}
		}
		
		return languages
	}
	
	func getRuntimeMinutes() async throws -> Int {
		let durationInSeconds = await CMTimeGetSeconds(try self.load(.duration))
		return Int(durationInSeconds / 60)
	}
}

extension [AVMetadataItem] {
	
	// String
	func getStringMetaDataValue(for identifier: AVMetadataIdentifier) async throws -> String {
		if let stringValue = await self.tryGetStringMetaDataValue(for: identifier) {
			return stringValue
		}
		throw ImportError.missingMetadata(type: identifier.rawValue)
	}

	func tryGetStringMetaDataValue(for identifier: AVMetadataIdentifier) async -> String? {
		do {
			return try await AVMetadataItem.metadataItems(from: self, filteredByIdentifier: identifier).first?.load(.stringValue)
		} catch {
			return nil
		}
	}
	
	func getStringMetaDataValue(for identifier: String) async throws -> String {
		if let stringValue = await self.tryGetStringMetaDataValue(for: identifier) {
			return stringValue
		}
		throw ImportError.missingMetadata(type: identifier)
	}

	func tryGetStringMetaDataValue(for identifier: String) async -> String? {
		do {
			return try await self.filter({ $0.identifier?.rawValue == identifier}).first?.load(.stringValue)
		} catch {
			return nil
		}
	}
	
	// Int
	func getIntMetaDataValue(for identifier: AVMetadataIdentifier) async throws -> Int {
		if let intValue = await self.tryGetIntMetaDataValue(for: identifier) {
			return intValue
		}
		throw ImportError.missingMetadata(type: identifier.rawValue)
	}

	func tryGetIntMetaDataValue(for identifier: AVMetadataIdentifier) async -> Int? {
		do {
			return try await AVMetadataItem.metadataItems(from: self, filteredByIdentifier: identifier).first?.load(.numberValue)?.intValue
		} catch {
			return nil
		}
	}
	
	func getIntMetaDataValue(for identifier: String) async throws -> Int {
		if let intValue = await self.tryGetIntMetaDataValue(for: identifier) {
			return intValue
		}
		throw ImportError.missingMetadata(type: identifier)
	}

	func tryGetIntMetaDataValue(for identifier: String) async -> Int? {
		do {
			return try await self.filter({ $0.identifier?.rawValue == identifier}).first?.load(.numberValue)?.intValue
		} catch {
			return nil
		}
	}

	// String Array
	func getStringArrayMetaDataValue(for identifier: String, creditCroup: String) async throws -> [String] {
		if let stringArrayValue = await self.tryGetStringArrayMetaDataValue(for: identifier, creditCroup: creditCroup) {
			return stringArrayValue
		}
		throw ImportError.missingMetadata(type: identifier)
	}

	func tryGetStringArrayMetaDataValue(for identifier: String, creditCroup: String) async -> [String]? {
		do {
			guard let xmlData = try await
					self.filter({ $0.identifier?.rawValue == identifier})
						.first?
						.load(.stringValue)?
						.data(using: .utf8) else { return nil }

			var format = PropertyListSerialization.PropertyListFormat.xml
			guard let plist = try? PropertyListSerialization.propertyList(from: xmlData, options: [], format: &format),
				  let dict = plist as? [String: Any] else { return nil }
			
			if creditCroup=="studio" {
				guard let studio = dict[creditCroup] as? String else { return nil }
				return [studio]
			}
			guard let items = dict[creditCroup] as? [[String: Any]] else { return nil }
			return items.compactMap { $0["name"] as? String }
		} catch {
			return nil
		}
	}
	
	// Date
	func getDateMetaDataValue(for identifier: AVMetadataIdentifier) async throws -> Date {
		if let date = await self.tryGetDateMetaDataValue(for: identifier) {
			return date
		}
		throw ImportError.missingMetadata(type: identifier.rawValue)
	}

	func tryGetDateMetaDataValue(for identifier: AVMetadataIdentifier) async -> Date? {
		do {
			return try await AVMetadataItem.metadataItems(from: self, filteredByIdentifier: identifier).first?.load(.dateValue)
		} catch {
			return nil
		}
	}
	
	// Artwork
	func tryGetImageMetaDataValue(artworkType: ArtworkType) async -> Data? {
		let artworks = AVMetadataItem.metadataItems(from: self, filteredByIdentifier: .commonIdentifierArtwork)
		if artworks.isEmpty { return nil }

		do {
			if artworks.endIndex > artworkType.index {
				return try await artworks[artworkType.index].load(.dataValue)
			}

			return try await artworks.first?.load(.dataValue)
		} catch {
			return nil
		}
	}
	
	func getGenres() async throws -> [String] {
		let userGenresString = await self.tryGetStringMetaDataValue(for: .iTunesMetadataUserGenre)
		let userGenres = userGenresString?.split(separator: ",").map{ $0.trimmingCharacters(in: .whitespaces) }
		if userGenres != nil { return userGenres! }
	
		let itunesRawGenreCode = try await self.filter({ $0.identifier?.rawValue == "itsk/gnre"}).first?.load(.dataValue)
		let itunesGenreCode = itunesRawGenreCode?.withUnsafeBytes { $0.load(as: UInt16.self).bigEndian }
		
		if let itunesGenreCode {
			let correctedItunesGenreCode = itunesGenreCode - 1
			let iTunesGenreName = itunesGenreCodes[correctedItunesGenreCode]
			
			if let iTunesGenreName {
				return [iTunesGenreName]
			}
		}
		
		return []
	}
	
	func getResolution() async throws -> HDVideoQuality {
		let resolutionIndex = await self.tryGetIntMetaDataValue(for: "itsk/hdvd") ?? 0 // When hd is not found its SD quality
		return HDVideoQuality(rawValue: resolutionIndex) ?? .sd
	}
}

fileprivate let itunesGenreCodes: [UInt16: String] = [
	 0: "Blues",
	 1: "Classic Rock",
	 2: "Country",
	 3: "Dance",
	 4: "Disco",
	 5: "Funk",
	 6: "Grunge",
	 7: "Hip-Hop",
	 8: "Jazz",
	 9: "Metal",
	10: "New Age",
	11: "Oldies",
	12: "Other",
	13: "Pop",
	14: "R&B",
	15: "Rap",
	16: "Reggae",
	17: "Rock",
	18: "Techno",
	19: "Industrial",
	20: "Alternative",
	21: "Ska",
	22: "Death Metal",
	23: "Pranks",
	24: "Soundtrack",
	25: "Euro-Techno",
	26: "Ambient",
	27: "Trip-Hop",
	28: "Vocal",
	29: "Jazz+Funk",
	30: "Fusion",
	31: "Trance",
	32: "Classical",
	33: "Instrumental",
	34: "Acid",
	35: "House",
	36: "Game",
	37: "Sound Clip",
	38: "Gospel",
	39: "Noise",
	40: "AlternRock",
	41: "Bass",
	42: "Soul",
	43: "Punk",
	44: "Space",
	45: "Meditative",
	46: "Instrumental Pop",
	47: "Instrumental Rock",
	48: "Ethnic",
	49: "Gothic",
	50: "Darkwave",
	51: "Techno-Industrial",
	52: "Electronic",
	53: "Pop-Folk",
	54: "Eurodance",
	55: "Dream",
	56: "Southern Rock",
	57: "Comedy",
	58: "Cult",
	59: "Gangsta",
	60: "Top 40",
	61: "Christian Rap",
	62: "Pop/Funk",
	63: "Jungle",
	64: "Native American",
	65: "Cabaret",
	66: "New Wave",
	67: "Psychadelic",
	68: "Rave",
	69: "Showtunes",
	70: "Trailer",
	71: "Lo-Fi",
	72: "Tribal",
	73: "Acid Punk",
	74: "Acid Jazz",
	75: "Polka",
	76: "Retro",
	77: "Musical",
	78: "Rock & Roll",
	79: "Hard Rock",
	80: "Folk",
	81: "Folk-Rock",
	82: "National Folk",
	83: "Swing",
	84: "Fast Fusion",
	85: "Bebob",
	86: "Latin",
	87: "Revival",
	88: "Celtic",
	89: "Bluegrass",
	90: "Avantgarde",
	91: "Gothic Rock",
	92: "Progressive Rock",
	93: "Psychedelic Rock",
	94: "Symphonic Rock",
	95: "Slow Rock",
	96: "Big Band",
	97: "Chorus",
	98: "Easy Listening",
	99: "Acoustic",
   100: "Humour",
   101: "Speech",
   102: "Chanson",
   103: "Opera",
   104: "Chamber Music",
   105: "Sonata",
   106: "Symphony",
   107: "Booty Bass",
   108: "Primus",
   109: "Porn Groove",
   110: "Satire",
   111: "Slow Jam",
   112: "Club",
   113: "Tango",
   114: "Samba",
   115: "Folklore",
   116: "Ballad",
   117: "Power Ballad",
   118: "Rhythmic Soul",
   119: "Freestyle",
   120: "Duet",
   121: "Punk Rock",
   122: "Drum Solo",
   123: "A Cappella",
   124: "Euro-House",
   125: "Dance Hall",
   126: "Goa",
   127: "Drum & Bass",
   128: "Club-House",
   129: "Hardcore",
   130: "Terror",
   131: "Indie",
   132: "BritPop",
   133: "Negerpunk",
   134: "Polsk Punk",
   135: "Beat",
   136: "Christian Gangsta Rap",
   137: "Heavy Metal",
   138: "Black Metal",
   139: "Crossover",
   140: "Contemporary Christian",
   141: "Christian Rock",
   142: "Merengue",
   143: "Salsa",
   144: "Thrash Metal",
   145: "Anime",
   146: "JPop",
   147: "Synthpop"
]
