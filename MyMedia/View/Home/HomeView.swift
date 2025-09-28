//
//  HomeView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 31.03.25.
//

import SwiftUI
import SwiftData
import AwesomeSwiftyComponents

struct HomeView: View {
	
	@Environment(\.modelContext) private var moc
	@Query(sort: \TvShow.title) private var tvShows: [TvShow]
	@Query(sort: \Movie.title) private var movies: [Movie]
	@Query(sort: \MediaCollection.title) private var collections: [MediaCollection]
	
	@AppStorage("selectedTab") private var selectedTab: String = Tabs.unwatched
	@AppStorage("sidebarCustomizations") private var tabViewCustomization: TabViewCustomization
	
	@AppStorage("sortOrderUnwatched") private var sortOrderUnwatched = SortOption.title
	@AppStorage("sortOrderFavorites") private var sortOrderFavorites = SortOption.title
	@AppStorage("sortOrderGenres") private var sortOrderGenres = SortOption.title
	@AppStorage("sortOrderMovies") private var sortOrderMovies = SortOption.title
	@AppStorage("sortOrderMoviesGenre") private var sortOrderMoviesGenre = SortOption.title
	@AppStorage("sortOrderTvShows") private var sortOrderTvShows = SortOption.title
	@AppStorage("sortOrderTvShowsGenre") private var sortOrderTvShowsGenre = SortOption.title
	
	@AppStorage("viewPreferenceUnwatched") private var viewPreferenceUnwatched = ViewOption.grid
	@AppStorage("viewPreferenceFavorites") private var viewPreferenceFavorites = ViewOption.grid
	@AppStorage("viewPreferenceGenres") private var viewPreferenceGenres = ViewOption.grid
	@AppStorage("viewPreferenceMovies") private var viewPreferenceMovies = ViewOption.grid
	@AppStorage("viewPreferenceMoviesGenre") private var viewPreferenceMoviesGenre = ViewOption.grid
	@AppStorage("viewPreferenceTvShows") private var viewPreferenceTvShows = ViewOption.grid
	@AppStorage("viewPreferenceTvShowsGenre") private var viewPreferenceTvShowsGenre = ViewOption.grid
	
	@AppStorage("useSectionsUnwatched") private var useSectionsUnwatched = true
	@AppStorage("useSectionsFavorites") private var useSectionsFavorites = true
	@AppStorage("useSectionsGenres") private var useSectionsGenres = true
	@AppStorage("useSectionsMovies") private var useSectionsMovies = true
	@AppStorage("useSectionsMoviesGenre") private var useSectionsMoviesGenre = true
	@AppStorage("useSectionsTvShows") private var useSectionsTvShows = true
	@AppStorage("useSectionsTvShowsGenre") private var useSectionsTvShowsGenre = true
	
	@Environment(CommandResource.self) private var commandResource
	
	@Environment(\.openURL) private var openURL
	
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
					LayoutSwitchingView(
						mediaItems: unwatched,
						sorting: $sortOrderUnwatched,
						viewPreference: $viewPreferenceUnwatched,
						useSections: $useSectionsUnwatched,
						navTitle: "Unwatched"
					)
					.navigationTitle("Unwatched")
					.id(Tabs.unwatched)
				}
				.customizationID(Tabs.unwatched)
				
				Tab("Favorites", systemImage: "star.fill", value: Tabs.favourites) {
					let favourites: [any MediaItem] = tvShows.filter({ $0.isFavorite }) + movies.filter({ $0.isFavorite })
					LayoutSwitchingView(
						mediaItems: favourites,
						sorting: $sortOrderFavorites,
						viewPreference: $viewPreferenceFavorites,
						useSections: $useSectionsFavorites,
						navTitle: "Favorites"
					)
					.id(Tabs.favourites)
				}
				.customizationID(Tabs.favourites)
				
				Tab("Genres", systemImage: SystemImages.genres, value: Tabs.genres) {
					GenresView(
						mediaItems: tvShows + movies,
						sortOrder: $sortOrderGenres,
						viewPreference: $viewPreferenceGenres,
						useSections: $useSectionsGenres
					)
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
					LayoutSwitchingView(
						mediaItems: movies,
						sorting: $sortOrderMovies,
						viewPreference: $viewPreferenceMovies,
						useSections: $useSectionsMovies,
						navTitle: "Movies"
					)
					.id(Tabs.movies)
				}
				.customizationID(Tabs.movies)
				
				Tab("Genres", systemImage: SystemImages.genres, value: Tabs.movieGenres) {
					GenresView(
						mediaItems: movies,
						sortOrder: $sortOrderMoviesGenre,
						viewPreference: $viewPreferenceMoviesGenre,
						useSections: $useSectionsMoviesGenre
					)
					.id(Tabs.movieGenres)
				}
				.customizationID(Tabs.movieGenres)
			}
			.customizationID(Tabs.moviesSection)
			
			TabSection("TV Shows") {
				Tab("All TV Shows", systemImage: SystemImages.tvShow, value: Tabs.tvShows) {
					LayoutSwitchingView(
						mediaItems: tvShows,
						sorting: $sortOrderTvShows,
						viewPreference: $viewPreferenceTvShows,
						useSections: $useSectionsTvShows,
						navTitle: "TV Shows"
					)
					.id(Tabs.tvShows)
				}
				.customizationID(Tabs.tvShows)
				
				Tab("Genres", systemImage: SystemImages.genres, value: Tabs.tvShowsGenres) {
					GenresView(
						mediaItems: tvShows,
						sortOrder: $sortOrderTvShowsGenre,
						viewPreference: $viewPreferenceTvShowsGenre,
						useSections: $useSectionsGenres
					)
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
								LayoutSwitchingView(
									mediaItems: collection.mediaItems,
									sorting: Bindable(collection).sort,
									viewPreference: Bindable(collection).viewPreference,
									useSections: Bindable(collection).useSections,
									navTitle: LocalizedStringKey(collection.title)
								) {
									CollectionHeaderView(collection: collection)
								}
								.environment(\.mediaContext, .collection(collection))
								.id(collection.id.uuidString)
							}
							.dropDestination(for: String.self) { ids in dropMediaItemOnCollection(target: collection, ids: ids) }
							.contextMenu { unpinButton }
							.customizationID(pinnedItem.id.uuidString)
						} else {
							Tab(pinnedItem.title, systemImage: pinnedItem.systemImageName, value: pinnedItem.id.uuidString) {
								NavigationStack {
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
		.alert(commandResource.errorTitle, isPresented: .constant(commandResource.errorMessage != nil)) {
			Button("OK"){ commandResource.clearError() }
			Button("Get Help") { openURL(URL(string: "https://github.com/photangralenphie/MyMedia/wiki/Help-%E2%80%90-Error-Codes")!) }
		} message: {
			commandResource.errorMessage ?? Text("Unknown Error")
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

