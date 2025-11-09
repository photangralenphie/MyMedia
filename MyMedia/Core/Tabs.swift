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
			case .unwatched:
				return LocalizedStringKey("Unwatched")
			case .favorites:
				return LocalizedStringKey("Favorites")
			case .genres:
				return LocalizedStringKey("Genres")
			case .collections:
				return LocalizedStringKey("Collections")
			case .search:
				return LocalizedStringKey("Search")
			case .movies:
				return LocalizedStringKey("All Movies")
			case .moviesGenres:
				return LocalizedStringKey("Genres")
			case .tvShows:
				return LocalizedStringKey("All TV Shows")
			case .tvShowsGenres:
				return LocalizedStringKey("Genres")
			case .tvShowsMiniSeries:
				return LocalizedStringKey("Mini-Series")
		}
	}
	
	var id: String { rawValue }
	
	var systemImage: String {
		switch self {
			case .unwatched:
				return "eye.slash"
			case .favorites:
				return "star.fill"
			case .genres:
				return "theatermasks"
			case .collections:
				return "star.square.on.square"
			case .search:
				return "magnifyingglass"
			case .movies:
				return "movieclapper"
			case .moviesGenres:
				return Self.genres.systemImage
			case .tvShows:
				return "tv"
			case .tvShowsGenres:
				return Self.genres.systemImage
			case .tvShowsMiniSeries:
				return "rectangle.stack.badge.play"
		}
	}
	
	public static let generalSection: String = "generalSection"
	public static let moviesSection: String = "moviesSection"
	public static let tvShowsSection: String = "tvShowsSection"
	public static let pinnedSection: String = "pinnedSection"
}
