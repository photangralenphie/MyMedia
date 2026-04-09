//
//  Tabs.swift
//  MyMedia
//
//  Created by Jonas Helmer on 09.11.25.
//

import SwiftUI

enum Tabs: String, Hashable {
	case unwatched = "unwatched"
	case favorites = "favorites"
	case genres = "genres"
	case collections = "collections"
	case search = "search"

	case movies = "movies"
	case moviesGenres = "moviesGenres"
	case tvShows = "tvShows"
	case tvShowsGenres = "tvShowsGenres"
	case tvShowsMiniSeries = "tvShowsMiniSeries"
	
	var title: LocalizedStringKey {
		switch self {
			case .unwatched: "Unwatched"
			case .favorites: "Favorites"
			case .genres: "Genres"
			case .collections: "Collections"
			case .search: "Search"
			case .movies: "All Movies"
			case .moviesGenres: "Genres"
			case .tvShows: "All TV Shows"
			case .tvShowsGenres: "Genres"
			case .tvShowsMiniSeries: "Mini-Series"
		}
	}
	
	var id: String { rawValue }
	
	var systemImage: String {
		switch self {
			case .unwatched: "eye.slash"
			case .favorites: "star.fill"
			case .genres: "theatermasks"
			case .collections: "star.square.on.square"
			case .search: "magnifyingglass"
			case .movies: "movieclapper"
			case .moviesGenres: Self.genres.systemImage
			case .tvShows: "tv"
			case .tvShowsGenres: Self.genres.systemImage
			case .tvShowsMiniSeries: "rectangle.stack.badge.play"
		}
	}
	
	public static let generalSection: String = "generalSection"
	public static let moviesSection: String = "moviesSection"
	public static let tvShowsSection: String = "tvShowsSection"
	public static let pinnedSection: String = "pinnedSection"
}
