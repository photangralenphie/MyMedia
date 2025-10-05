//
//  LayoutConstant.swift
//  MyMedia
//
//  Created by Jonas Helmer on 12.04.25.
//

import CoreFoundation

public struct LayoutConstants {
	// Artwork
	public static let cornerRadius: CGFloat = 20
	public static let artworkWidth: CGFloat = 300
	public static let artworkHeight: CGFloat = 168.75
	
	// Settings
	public static let settingsWidth: CGFloat = 350
	
	// Grid
	public static let gridSpacing: CGFloat = 20
	
	private init() {}
}

public struct SystemImages {
	public static let movie = "movieclapper"
	public static let tvShow = "tv"
	public static let collections = "star.square.on.square"
	
	public static let genres = "theatermasks"
	
	private init() {}
}

public struct Tabs {
	public static let unwatched: String = "unwatched"
	public static let favourites: String = "favourites"
	public static let genres: String = "genres"
	public static let collections: String = "collections"
	public static let movies: String = "movies"
	public static let movieGenres: String = "movieGenres"
	public static let tvShows: String = "tvShows"
	public static let tvShowsGenres: String = "tvShowsGenres"
	
	public static let generalSection: String = "generalSection"
	public static let moviesSection: String = "moviesSection"
	public static let tvShowsSection: String = "tvShowsSection"
	public static let pinnedSection: String = "pinnedSection"
	
	private init() {}
}

public struct PreferenceKeys {
	public static let autoPlay: String = "autoPlay"
	public static let autoQuit: String = "autoQuit"
	public static let downSizeArtwork: String = "downSizeArtwork"
	public static let downSizeArtworkWidth: String = "downSizeArtworkWidth"
	public static let downSizeArtworkHeight: String = "downSizeArtworkHeight"
	public static let downSizeCollectionArtwork: String = "downSizeCollectionArtwork"
	public static let playButtonInArtwork: String = "playButtonInArtwork"
	public static let playerStyle: String = "playerStyle"
	public static let preferShortDescription = "preferShortDescription"
	public static let showLanguageFlags: String = "showLanguageFlags"
	public static let useInAppPlayer: String = "useInAppPlayer"
	
	private init() {}
}
