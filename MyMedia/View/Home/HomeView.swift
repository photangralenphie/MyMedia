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
	
	public static let generalSection: String = "generalSection"
	public static let moviesSection: String = "moviesSection"
	public static let tvShowsSection: String = "tvShowsSection"
	public static let pinnedSection: String = "pinnedSection"
}


struct HomeView: View {
	
	@Environment(\.modelContext) private var moc
	@Query(sort: \TvShow.title) private var tvShows: [TvShow]
	@Query(sort: \Movie.title) private var movies: [Movie]
	@Query(sort: \MediaCollection.title) private var collections: [MediaCollection]
	
	@AppStorage("selectedTab") private var selectedTab: String = "Unwatched"
	@AppStorage("sidebarCustomizations") private var tabViewCustomization: TabViewCustomization
	
	@AppStorage("sortOrderUnwatched") private var sortOrderUnwatched = SortOption.title
	@AppStorage("sortOrderFavorites") private var sortOrderFavorites = SortOption.title
	@AppStorage("sortOrderGenres") private var sortOrderGenres = SortOption.title
	@AppStorage("sortOrderMovies") private var sortOrderMovies = SortOption.title
	@AppStorage("sortOrderMoviesGenre") private var sortOrderMoviesGenre = SortOption.title
	@AppStorage("sortOrderTvShows") private var sortOrderTvShows = SortOption.title
	@AppStorage("sortOrderTvShowsGenre") private var sortOrderTvShowsGenre = SortOption.title
	
	var pinnedItems: [any IsPinnable] {
		(tvShows + movies + collections).filter({ $0.isPinned })
	}
	
    var body: some View {
		TabView(selection: $selectedTab) {
//			Tab("Recent", systemImage: "calendar") {
//				Text("Recent")
//					.navigationTitle("Recent")
//			}
			TabSection("Library") {
				Tab("Unwatched", systemImage: "eye.slash", value: Tabs.unwatched) {
					let unwatched: [any MediaItem] = tvShows.filter({ !$0.isWatched }) + movies.filter({ !$0.isWatched })
					GridView(mediaItems: unwatched, sorting: $sortOrderUnwatched, navTitle: "Unwatched")
						.id(Tabs.unwatched)
				}
				.customizationID(Tabs.unwatched)
				
				Tab("Favorites", systemImage: "star.fill", value: Tabs.favourites) {
					let favourites: [any MediaItem] = tvShows.filter({ $0.isFavorite }) + movies.filter({ $0.isFavorite })
					GridView(mediaItems: favourites, sorting: $sortOrderFavorites, navTitle: "Favorites")
						.id(Tabs.favourites)
				}
				.customizationID(Tabs.favourites)
				
				Tab("Genres", systemImage: SystemImages.genres, value: Tabs.genres) {
					GenresView(mediaItems: tvShows + movies, sortOrder: $sortOrderGenres)
						.id(Tabs.genres)
				}
				
				Tab("Collections", systemImage: SystemImages.collections, value: Tabs.collections) {
					CollectionsView()
						.id(Tabs.collections)
				}
				.customizationID(Tabs.genres)
			}
			.customizationID(Tabs.generalSection)
			
//			Tab("Search", systemImage: "magnifyingglass") {
//				Text("Search")
//					.navigationTitle("Search")
//			}
			
			TabSection("Movies") {
				Tab("All Movies", systemImage: SystemImages.movie, value: Tabs.movies) {
					GridView(mediaItems: movies, sorting: $sortOrderMovies, navTitle: "Movies")
						.id(Tabs.movies)
				}
				.customizationID(Tabs.movies)
				
				Tab("Genres", systemImage: SystemImages.genres, value: Tabs.movieGenres) {
					GenresView(mediaItems: movies, sortOrder: $sortOrderMoviesGenre)
						.id(Tabs.movieGenres)
				}
				.customizationID(Tabs.movieGenres)
			}
			.customizationID(Tabs.moviesSection)
			
			TabSection("TV Shows") {
				Tab("All TV Shows", systemImage: SystemImages.tvShow, value: Tabs.tvShows) {
					GridView(mediaItems: tvShows, sorting: $sortOrderTvShows, navTitle: "TV Shows")
						.id(Tabs.tvShows)
				}
				.customizationID(Tabs.tvShows)
				
				Tab("Genres", systemImage: SystemImages.genres, value: Tabs.tvShowsGenres) {
					GenresView(mediaItems: tvShows, sortOrder: $sortOrderTvShowsGenre)
						.id(Tabs.tvShowsGenres)
				}
				.customizationID(Tabs.tvShowsGenres)
			}
			.customizationID(Tabs.tvShowsSection)
			
			if !pinnedItems.isEmpty {
				TabSection("Pinned") {
					ForEach(pinnedItems, id: \.id) { pinnedItem in
						let unpinButton = Button("Unpin", systemImage: "pin.slash") { unpinItem(pinnedItem) }

						if let collection = pinnedItem as? MediaCollection {
							Tab(collection.title, systemImage: collection.systemImageName, value: collection.id.uuidString) {
								GridView(mediaItems: collection.mediaItems, sorting: .constant(SortOption.title), navTitle: LocalizedStringKey(collection.title)) {
									CollectionHeaderView(collection: collection)
								}
								.id(collection.id.uuidString)
							}
							.dropDestination(for: String.self) { ids in dropMediaItemOnCollection(target: collection, ids: ids) }
							.contextMenu { unpinButton }
							.customizationID(pinnedItem.id.uuidString)
						} else {
							Tab(pinnedItem.title, systemImage: pinnedItem.systemImageName, value: pinnedItem.id.uuidString) {
								switch pinnedItem {
									case let tvShow as TvShow:
										TvShowDetailView(tvShow: tvShow)
											.id(tvShow.id.uuidString)
									case let movie as Movie:
										MovieDetailView(movie: movie)
											.id(movie.id.uuidString)
									default:
										EmptyView()
								}
							}
							.contextMenu { unpinButton }
							.customizationID(pinnedItem.id.uuidString)
						}
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
	
	func dropMediaItemOnCollection(target: MediaCollection, ids: [any Transferable]) {
		let allMediaItems: [any MediaItem] = tvShows + movies
		for id in ids {
			if let uuid = id as? String,
			   let itemToAdd = allMediaItems.first(where: { $0.id.uuidString == uuid }) {
				target.addMediaItem(itemToAdd)
			}
		}
	}
		
	func unpinItem(_ pinnedItem: any IsPinnable) {
		if var item = pinnedItems.filter({ $0.id == pinnedItem.id}).first {
			withAnimation {
				item.isPinned = false
				try? moc.save()
			}
		}
	}
}
