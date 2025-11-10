//
//  MediaImporter.swift
//  MyMedia
//
//  Created by Jonas Helmer on 30.03.25.
//

import SwiftUI
import SwiftData
@preconcurrency import AVFoundation

@ModelActor
actor MediaImporter {
	
	private func getAssetAndMetadata(path: URL) async throws -> (asset: AVURLAsset, metadata: [AVMetadataItem]) {
		let asset = AVURLAsset(url: path)
		let metadata = try await asset.load(.metadata)
		return (asset, metadata)
	}
	
	public func importFromFile(path: URL) async throws {

		let (asset, metadata) = try await getAssetAndMetadata(path: path)
		
		let kind = await self.tryGetIntMetaDataValue(metadata: metadata, for: "itsk/stik")
		
		if kind == nil  {
			throw ImportError.noMetadataFound(fileName: path.lastPathComponent)
		}
		
		if(kind == 9){
			 try await readMovieMetadata(metadata: metadata, asset: asset)
		}
	
		if(kind == 10) {
			try await readTvMetadata(metaData: metadata, asset: asset, source: path)
		}
	}
	
	private func readTvMetadata(metaData: [AVMetadataItem], asset: AVURLAsset, source: URL) async throws {
		let showTitle = try await self.getStringMetaDataValue(metadata: metaData, for: .commonIdentifierArtist)
		
		let existingTvShows = try await fetchCurrentTvShows()
		var show = existingTvShows.filter { $0.title == showTitle }.first
		
		if show == nil {
			show = try await createTvShowFromEpisode(metadata: metaData)
			modelContext.insert(show!)
		}
		
		guard let show = show else {
			throw ImportError.unknown(message: "Something went wrong creating a TV show from file \(source.absoluteString)")
		}
		
		let episode = try await createEpisodeFromFile(metadata: metaData, asset: asset)
		show.episodes.append(episode)
		
		try modelContext.save()
	}
	
	private func readMovieMetadata(metadata: [AVMetadataItem], asset: AVURLAsset) async throws {
		let movie = try await createMovieFromFile(metadata: metadata, asset: asset)
		modelContext.insert(movie)
		try modelContext.save()
	}
	
	private func createMovieFromFile(metadata: [AVMetadataItem], asset: AVURLAsset) async throws -> Movie {
		let artwork = await self.tryGetImageMetaDataValue(metadata: metadata, artworkType: .moviePoster)
		let title = try await self.getStringMetaDataValue(metadata: metadata, for: .commonIdentifierTitle)
		let genre = try await self.getGenres(metadata: metadata)
		let durationMinutes = try await asset.getRuntimeMinutes()
		let releaseDate = try await self.getDateMetaDataValue(metadata: metadata, for: .iTunesMetadataReleaseDate)
		let shortDescription = await self.tryGetStringMetaDataValue(metadata: metadata, for: "itsk/desc")
		let longDescription = await self.tryGetStringMetaDataValue(metadata: metadata, for: "itsk/ldes")
		let producers = await self.tryGetStringArrayMetaDataValue(metadata: metadata, for: "itlk/com.apple.iTunes.iTunMOVI", creditGroup: "producers") ?? []
		let executiveProducers = (await self.tryGetStringMetaDataValue(metadata: metadata, for: "itsk/%A9xpd") ?? "").split(separator: ", ").map { String($0) }
		let cast = await self.tryGetStringArrayMetaDataValue(metadata: metadata, for: "itlk/com.apple.iTunes.iTunMOVI", creditGroup: "cast") ?? []
		let directors = await self.tryGetStringArrayMetaDataValue(metadata: metadata, for: "itlk/com.apple.iTunes.iTunMOVI", creditGroup: "directors") ?? []
		let coDirectors = await self.tryGetStringArrayMetaDataValue(metadata: metadata, for: "itlk/com.apple.iTunes.iTunMOVI", creditGroup: "codirectors") ?? []
		let screenwriters = await self.tryGetStringArrayMetaDataValue(metadata: metadata, for: "itlk/com.apple.iTunes.iTunMOVI", creditGroup: "screenwriters") ?? []
		let composer = await self.tryGetStringMetaDataValue(metadata: metadata, for: .iTunesMetadataComposer)
		let studio = await self.tryGetStringArrayMetaDataValue(metadata: metadata, for: "itlk/com.apple.iTunes.iTunMOVI", creditGroup: "studio")?.first
		let rating = await self.tryGetStringMetaDataValue(metadata: metadata, for: "itlk/com.apple.iTunes.iTunEXTC")
		let languages = try await asset.getAudioLanguages()
		let resolution = try await self.getResolution(metadata: metadata)
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
		let title = try await self.getStringMetaDataValue(metadata: metadata, for: .commonIdentifierArtist)
		let date = try await self.getDateMetaDataValue(metadata: metadata, for: .iTunesMetadataReleaseDate)
		let year = Calendar.current.component(.year, from: date)
		let genre = try await self.getGenres(metadata: metadata)
		let seriesDescription = await self.tryGetStringMetaDataValue(metadata: metadata, for: "itsk/sdes")
		let artwork = await self.tryGetImageMetaDataValue(metadata: metadata, artworkType: .tvPoster)
		
		return TvShow(
			title: title,
			year: year,
			genre: genre,
			showDescription: seriesDescription,
			artwork: artwork
		)
	}
	
	private func createEpisodeFromFile(metadata: [AVMetadataItem], asset: AVURLAsset) async throws -> Episode {
		let artwork = await self.tryGetImageMetaDataValue(metadata: metadata, artworkType: .episodeImage)
		let seasonNumber = try await self.getIntMetaDataValue(metadata: metadata, for: "itsk/tvsn")
		let episodeNumber = try await self.getIntMetaDataValue(metadata: metadata, for: "itsk/tves")
		let title = try await self.getStringMetaDataValue(metadata: metadata, for: .commonIdentifierTitle)
		let durationMinutes = try await asset.getRuntimeMinutes()
		let releaseDate = try await self.getDateMetaDataValue(metadata: metadata, for: .iTunesMetadataReleaseDate)
		let shortDescription = await self.tryGetStringMetaDataValue(metadata: metadata, for: "itsk/desc")
		let longDescription = await self.tryGetStringMetaDataValue(metadata: metadata, for: "itsk/ldes")
		let producers = await self.tryGetStringArrayMetaDataValue(metadata: metadata, for: "itlk/com.apple.iTunes.iTunMOVI", creditGroup: "producers") ?? []
		let executiveProducers = (await self.tryGetStringMetaDataValue(metadata: metadata, for: "itsk/%A9xpd") ?? "").split(separator: ", ").map { String($0) }
		let cast = await self.tryGetStringArrayMetaDataValue(metadata: metadata, for: "itlk/com.apple.iTunes.iTunMOVI", creditGroup: "cast") ?? []
		let directors = await self.tryGetStringArrayMetaDataValue(metadata: metadata, for: "itlk/com.apple.iTunes.iTunMOVI", creditGroup: "directors") ?? []
		let coDirectors = await self.tryGetStringArrayMetaDataValue(metadata: metadata, for: "itlk/com.apple.iTunes.iTunMOVI", creditGroup: "codirectors") ?? []
		let screenwriters = await self.tryGetStringArrayMetaDataValue(metadata: metadata, for: "itlk/com.apple.iTunes.iTunMOVI", creditGroup: "screenwriters") ?? []
		let composer = await self.tryGetStringMetaDataValue(metadata: metadata, for: .iTunesMetadataComposer)
		let studio = await self.tryGetStringArrayMetaDataValue(metadata: metadata, for: "itlk/com.apple.iTunes.iTunMOVI", creditGroup: "studio")?.first
		let network = await self.tryGetStringMetaDataValue(metadata: metadata, for: "itsk/tvnn")
		let rating = await self.tryGetStringMetaDataValue(metadata: metadata, for: "itlk/com.apple.iTunes.iTunEXTC")
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
		return try modelContext.fetch(descriptor)
	}
	
	public func updateMediaItem(mediaItem: any MediaItem) async throws {
		switch mediaItem {
			case let movie as Movie:
				try await updateMovie(movie: movie)
			case let tvShow as TvShow:
				try await updateTvShow(tvShow: tvShow)
			case let episode as Episode:
				try await updateEpisode(episode: episode)
			default:
				throw ImportError.unknown(message: "Media is not a movie, TV show or episode.")
		}
		
		try modelContext.save()
	}
	
	public func updateMovie(movie: Movie) async throws {
		if let url = movie.url, url.startAccessingSecurityScopedResource() {
			defer { url.stopAccessingSecurityScopedResource() }
			
			let (asset, metadata) = try await getAssetAndMetadata(path: url)
			let update = try await createMovieFromFile(metadata: metadata, asset: asset)
			
			movie.artwork = update.artwork
			movie.title = update.title
			movie.genre = update.genre
			movie.durationMinutes = update.durationMinutes
			movie.releaseDate = update.releaseDate
			movie.shortDescription = update.shortDescription
			movie.longDescription = update.longDescription
			movie.cast = update.cast
			movie.producers = update.producers
			movie.executiveProducers = update.executiveProducers
			movie.directors = update.directors
			movie.coDirectors = update.coDirectors
			movie.screenwriters = update.screenwriters
			movie.composer = update.composer
			movie.studio = update.studio
			movie.hdVideoQuality = update.hdVideoQuality
			movie.rating = update.rating
			movie.languages = update.languages
		}
	}
	
	public func updateTvShow(tvShow: TvShow) async throws {
		if tvShow.episodes.count == 0 {
			throw ImportError.unknown(message: "TV show has no episodes.")
		}
		
		if let url = tvShow.episodes[0].url, url.startAccessingSecurityScopedResource() {
			defer { url.stopAccessingSecurityScopedResource() }
			
			let (_, metadata) = try await getAssetAndMetadata(path: url)
			let update = try await createTvShowFromEpisode(metadata: metadata)
			
			tvShow.title = update.title
			tvShow.year = update.year
			tvShow.genre = update.genre
			tvShow.showDescription = update.showDescription
			tvShow.artwork = update.artwork
		}
		
		for episode in tvShow.episodes {
			try await updateEpisode(episode: episode)
		}
	}
	
	public func updateEpisode(episode: Episode) async throws {
		if let url = episode.url, url.startAccessingSecurityScopedResource() {
			defer { url.stopAccessingSecurityScopedResource() }
			
			let (asset, metadata) = try await getAssetAndMetadata(path: url)
			let update = try await createEpisodeFromFile(metadata: metadata, asset: asset)
			
			episode.artwork = update.artwork
			episode.season = update.season
			episode.episode = update.episode
			episode.title = update.title
			episode.durationMinutes = update.durationMinutes
			episode.releaseDate = update.releaseDate
			episode.episodeShortDescription = update.episodeShortDescription
			episode.episodeLongDescription = update.episodeLongDescription
			episode.cast = update.cast
			episode.producers = update.producers
			episode.executiveProducers = update.executiveProducers
			episode.directors = update.directors
			episode.coDirectors = update.coDirectors
			episode.screenwriters = update.screenwriters
			episode.composer = update.composer
			episode.studio = update.studio
			episode.network = update.network
			episode.rating = update.rating
			episode.languages = update.languages
		}
	}
	
	public func getArtworks(url: URL?) async throws -> Data? {
		if let url, url.startAccessingSecurityScopedResource() {
			defer { url.stopAccessingSecurityScopedResource() }
			
			let (_, metadata) = try await getAssetAndMetadata(path: url)
			return await self.tryGetImageMetaDataValue(metadata: metadata, artworkType: .tvPoster)
		}
		return nil
	}
	
	private func getStringMetaDataValue(metadata: [AVMetadataItem], for identifier: AVMetadataIdentifier) async throws -> String {
		if let stringValue = await tryGetStringMetaDataValue(metadata: metadata, for: identifier) {
			return stringValue
		}
		throw ImportError.missingMetadata(type: identifier.rawValue)
	}

	private func tryGetStringMetaDataValue(metadata: [AVMetadataItem], for identifier: AVMetadataIdentifier) async -> String? {
		do {
			return try await AVMetadataItem.metadataItems(from: metadata, filteredByIdentifier: identifier).first?.load(.stringValue)
		} catch {
			return nil
		}
	}
	
	private func getStringMetaDataValue(metadata: [AVMetadataItem], for identifier: String) async throws -> String {
		if let stringValue = await tryGetStringMetaDataValue(metadata: metadata, for: identifier) {
			return stringValue
		}
		throw ImportError.missingMetadata(type: identifier)
	}

	private func tryGetStringMetaDataValue(metadata: [AVMetadataItem], for identifier: String) async -> String? {
		do {
			return try await metadata.filter({ $0.identifier?.rawValue == identifier}).first?.load(.stringValue)
		} catch {
			return nil
		}
	}
	
	private func getIntMetaDataValue(metadata: [AVMetadataItem], for identifier: AVMetadataIdentifier) async throws -> Int {
		if let intValue = await tryGetIntMetaDataValue(metadata: metadata, for: identifier) {
			return intValue
		}
		throw ImportError.missingMetadata(type: identifier.rawValue)
	}

	private func tryGetIntMetaDataValue(metadata: [AVMetadataItem], for identifier: AVMetadataIdentifier) async -> Int? {
		do {
			return try await AVMetadataItem.metadataItems(from: metadata, filteredByIdentifier: identifier).first?.load(.numberValue)?.intValue
		} catch {
			return nil
		}
	}
	
	private func getIntMetaDataValue(metadata: [AVMetadataItem], for identifier: String) async throws -> Int {
		if let intValue = await tryGetIntMetaDataValue(metadata: metadata, for: identifier) {
			return intValue
		}
		throw ImportError.missingMetadata(type: identifier)
	}

	private func tryGetIntMetaDataValue(metadata: [AVMetadataItem], for identifier: String) async -> Int? {
		do {
			return try await metadata.filter({ $0.identifier?.rawValue == identifier}).first?.load(.numberValue)?.intValue
		} catch {
			return nil
		}
	}

	private func getStringArrayMetaDataValue(metadata: [AVMetadataItem], for identifier: String, creditCroup: String) async throws -> [String] {
		if let stringArrayValue = await tryGetStringArrayMetaDataValue(metadata: metadata, for: identifier, creditGroup: creditCroup) {
			return stringArrayValue
		}
		throw ImportError.missingMetadata(type: identifier)
	}

	private func tryGetStringArrayMetaDataValue(metadata: [AVMetadataItem], for identifier: String, creditGroup: String) async -> [String]? {
		do {
			guard let xmlData = try await
					metadata.filter({ $0.identifier?.rawValue == identifier})
						.first?
						.load(.stringValue)?
						.data(using: .utf8) else { return nil }

			var format = PropertyListSerialization.PropertyListFormat.xml
			guard let plist = try? PropertyListSerialization.propertyList(from: xmlData, options: [], format: &format),
				  let dict = plist as? [String: Any] else { return nil }
			
			if creditGroup == "studio" {
				guard let studio = dict[creditGroup] as? String else { return nil }
				return [studio]
			}
			guard let items = dict[creditGroup] as? [[String: Any]] else { return nil }
			return items.compactMap { $0["name"] as? String }
		} catch {
			return nil
		}
	}
	
	private func getDateMetaDataValue(metadata: [AVMetadataItem], for identifier: AVMetadataIdentifier) async throws -> Date {
		if let date = await tryGetDateMetaDataValue(metadata: metadata, for: identifier) {
			return date
		}
		throw ImportError.missingMetadata(type: identifier.rawValue)
	}

	private func tryGetDateMetaDataValue(metadata: [AVMetadataItem], for identifier: AVMetadataIdentifier) async -> Date? {
		do {
			return try await AVMetadataItem.metadataItems(from: metadata, filteredByIdentifier: identifier).first?.load(.dateValue)
		} catch {
			return nil
		}
	}
	
	private func tryGetImageMetaDataValue(metadata: [AVMetadataItem], artworkType: ArtworkType) async -> Data? {
		let artworks = AVMetadataItem.metadataItems(from: metadata, filteredByIdentifier: .commonIdentifierArtwork)
		if artworks.isEmpty { return nil }
		
		var imageData: Data?
		do {
			if artworks.endIndex > artworkType.index {
				imageData = try await artworks[artworkType.index].load(.dataValue)
			} else {
				imageData = try await artworks.first?.load(.dataValue)
			}
		} catch {
			return nil
		}
		
		let doDownsize = UserDefaults.standard.bool(forKey: PreferenceKeys.downSizeArtwork)
		if let imageData, doDownsize, let image = NSImage(data: imageData) {
			let maxSize = MetadataUtil.getMaxImageSize()
			let newSize = MetadataUtil.getDownSizedImageSize(originalSize: image.size, maxSize: maxSize)
			return MetadataUtil.downSizeImage(imageData: imageData, newSize: newSize)
		}
		
		return imageData
	}
	
	private func getGenres(metadata: [AVMetadataItem]) async throws -> [String] {
		let userGenresString = await tryGetStringMetaDataValue(metadata: metadata, for: .iTunesMetadataUserGenre)
		let userGenres = userGenresString?.split(separator: ",").map{ $0.trimmingCharacters(in: .whitespaces) }
		if userGenres != nil { return userGenres! }
	
		let iTunesRawGenreCode = try await metadata.filter({ $0.identifier?.rawValue == "itsk/gnre"}).first?.load(.dataValue)
		let iTunesGenreCode = iTunesRawGenreCode?.withUnsafeBytes { $0.load(as: UInt16.self).bigEndian }
		
		if let iTunesGenreCode {
			let correctedITunesGenreCode = iTunesGenreCode - 1
			let iTunesGenreName = iTunesGenreCodes[correctedITunesGenreCode]
			
			if let iTunesGenreName {
				return [iTunesGenreName]
			}
		}
		
		return []
	}
	
	private func getResolution(metadata: [AVMetadataItem]) async throws -> HDVideoQuality {
		let resolutionIndex = await tryGetIntMetaDataValue(metadata: metadata, for: "itsk/hdvd") ?? 0 // When hd is not found it's SD quality
		return HDVideoQuality(rawValue: resolutionIndex) ?? .sd
	}
	
	public static func showImportError(_ error: ImportError) {
		Task { @MainActor in
			CommandResource.shared.showError(message: error.errorDescription, title: "Error while Importing", errorCode: error.errorCode)
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

fileprivate let iTunesGenreCodes: [UInt16: String] = [
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
