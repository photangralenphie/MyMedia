//
//  HomeView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 31.03.25.
//

import SwiftUI
import SwiftData
import AwesomeSwiftyComponents

struct Tabs {
	public static let unwatched: String = "unwatched"
	public static let favourites: String = "favourites"
	public static let genres: String = "genres"
	public static let collections: String = "collections"
	public static let movies: String = "movies"
	public static let movieGenres: String = "movieGenres"
	public static let tvShows: String = "tvShows"
	public static let tvShowsGenres: String = "tvShowsGenres"
	
	public static let moviesSection: String = "moviesSection"
	public static let tvShowsSection: String = "tvShowsSection"
	public static let pinnedSection: String = "pinnedSection"
}


struct HomeView: View {
	
	@Environment(\.modelContext) private var moc
	@Query(sort: \TvShow.title) private var tvShows: [TvShow]
	@Query(sort: \Movie.title) private var movies: [Movie]
	
	@AppStorage("selectedTab") private var selectedTab: String = "Unwatched"
	@AppStorage("sidebarCustomizations") private var tabViewCustomization: TabViewCustomization
	
	@AppStorage("sortOrderUnwatched") private var sortOrderUnwatched = SortOption.title
	@AppStorage("sortOrderFavorites") private var sortOrderFavorites = SortOption.title
	@AppStorage("sortOrderGenres") private var sortOrderGenres = SortOption.title
	@AppStorage("sortOrderMovies") private var sortOrderMovies = SortOption.title
	@AppStorage("sortOrderMoviesGenre") private var sortOrderMoviesGenre = SortOption.title
	@AppStorage("sortOrderTvShows") private var sortOrderTvShows = SortOption.title
	@AppStorage("sortOrderTvShowsGenre") private var sortOrderTvShowsGenre = SortOption.title
	
	var pinned: [any MediaItem] {
		tvShows.filter({ $0.isPinned }) + movies.filter({ $0.isPinned })
	}
	
    var body: some View {
		TabView(selection: $selectedTab) {
//			Tab("Recent", systemImage: "calendar") {
//				Text("Recent")
//					.navigationTitle("Recent")
//			}
			TabSection {
				Tab("Unwatched", systemImage: "eye.slash", value: Tabs.unwatched) {
					let unwatched: [any MediaItem] = tvShows.filter({ !$0.isWatched }) + movies.filter({ !$0.isWatched })
					GridView(mediaItems: unwatched, sorting: $sortOrderUnwatched, navTitle: "Unwatched")
						.id(Tabs.unwatched)
				}
				
				Tab("Favorites", systemImage: "star.fill", value: Tabs.favourites) {
					let favourites: [any MediaItem] = tvShows.filter({ $0.isFavorite }) + movies.filter({ $0.isFavorite })
					GridView(mediaItems: favourites, sorting: $sortOrderFavorites, navTitle: "Favorites")
						.id(Tabs.favourites)
				}
				
				Tab("Genres", systemImage: "theatermasks", value: Tabs.genres) {
					GenresView(mediaItems: tvShows + movies, sortOrder: $sortOrderGenres)
						.id(Tabs.genres)
				}
				
				Tab("Collections", systemImage: "star.square.on.square", value: Tabs.collections) {
					CollectionsView()
						.id(Tabs.collections)
				}
			}
			
//			Tab("Search", systemImage: "magnifyingglass") {
//				Text("Search")
//					.navigationTitle("Search")
//			}
			
			TabSection("Movies") {
				Tab("All Movies", systemImage: "movieclapper", value: Tabs.movies) {
					GridView(mediaItems: movies, sorting: $sortOrderMovies, navTitle: "Movies")
						.id(Tabs.movies)
				}
				.customizationID(Tabs.movies)
				
				Tab("Genres", systemImage: "theatermasks", value: Tabs.movieGenres) {
					GenresView(mediaItems: movies, sortOrder: $sortOrderMoviesGenre)
						.id(Tabs.movieGenres)
				}
				.customizationID(Tabs.movieGenres)
			}
			.customizationID(Tabs.moviesSection)
			
			TabSection("TV Shows") {
				Tab("All TV Shows", systemImage: "tv", value: Tabs.tvShows) {
					GridView(mediaItems: tvShows, sorting: $sortOrderTvShows, navTitle: "TV Shows")
						.id(Tabs.tvShows)
				}
				.customizationID(Tabs.tvShows)
				
				Tab("Genres", systemImage: "theatermasks", value: Tabs.tvShowsGenres) {
					GenresView(mediaItems: tvShows, sortOrder: $sortOrderTvShowsGenre)
						.id(Tabs.tvShowsGenres)
				}
				.customizationID(Tabs.tvShowsGenres)
			}
			.customizationID(Tabs.tvShowsSection)
			
			if !pinned.isEmpty {
				TabSection("Pinned") {
					ForEach(pinned, id: \.id) { mediaItem in
						Tab(mediaItem.title, systemImage: mediaItem is Movie ? "movieclapper" : "tv", value: mediaItem.id.uuidString) {
							switch mediaItem {
								case let tvShow as TvShow:
									TvShowDetailView(tvShow: tvShow)
										.id(mediaItem.id.uuidString)
								case let movie as Movie:
									MovieDetailView(movie: movie)
										.id(mediaItem.id.uuidString)
								default:
									Text("Episodes are not yet supported as Pins.")
							}
						}
						.contextMenu {
							Button("Unpin") {
								var pinnedItem = pinned.filter { $0.id == mediaItem.id}.first
								pinnedItem?.togglePinned()
							}
						}
						.customizationID(mediaItem.id.uuidString)
					}
				}
				.customizationID(Tabs.pinnedSection)
			}
		}
		.tabViewCustomization($tabViewCustomization)
		.tabViewStyle(.sidebarAdaptable)
		.tabViewSidebarBottomBar() {
			ImportingView()
		}
    }
}
