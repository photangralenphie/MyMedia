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
	@Environment(CommandResource.self) var commandResource
	@Query(sort: \TvShow.title) private var tvShows: [TvShow]
	@Query(sort: \Movie.title) private var movies: [Movie]
	@State private var isImporting: Bool = false
	@State private var errorMessage: String?
	
	@AppStorage("sortOrderUnwatched") private var sortOrderUnwatched = SortOption.title
	@AppStorage("sortOrderFavorites") private var sortOrderFavorites = SortOption.title
	@AppStorage("sortOrderGenres") private var sortOrderGenres = SortOption.title
	@AppStorage("sortOrderMovies") private var sortOrderMovies = SortOption.title
	@AppStorage("sortOrderMoviesGenre") private var sortOrderMoviesGenre = SortOption.title
	@AppStorage("sortOrderTvShows") private var sortOrderTvShows = SortOption.title
	@AppStorage("sortOrderTvShowsGenre") private var sortOrderTvShowsGenre = SortOption.title
	
    var body: some View {
		
		@Bindable var commandResource = commandResource
		
		TabView {
//			Tab("Recent", systemImage: "calendar") {
//				Text("Recent")
//					.navigationTitle("Recent")
//			}
			
			Tab("Unwatched", systemImage: "eye.slash") {
				let unwatched: [any Watchable] = tvShows.filter({ !$0.isWatched }) + movies.filter({ !$0.isWatched })
				GridView(watchables: unwatched, sorting: $sortOrderUnwatched, navTitle: "Unwatched")
			}
			
			Tab("Favorites", systemImage: "star.fill") {
				let favorites: [any Watchable] = tvShows.filter({ $0.isFavorite }) + movies.filter({ $0.isFavorite })
				GridView(watchables: favorites, sorting: $sortOrderFavorites, navTitle: "Favorites")
			}
			
			Tab("Genres", systemImage: "theatermasks") {
				GenresView(watchables: tvShows + movies, sortOrder: $sortOrderGenres)
					.id("CommonGenres")
			}
			
//			Tab("Search", systemImage: "magnifyingglass") {
//				Text("Search")
//					.navigationTitle("Search")
//			}
			
			TabSection("Movies") {
				Tab("All Movies", systemImage: "movieclapper") {
					GridView(watchables: movies, sorting: $sortOrderMovies, navTitle: "Movies")
				}
				Tab("Genres", systemImage: "theatermasks") {
					GenresView(watchables: movies, sortOrder: $sortOrderMoviesGenre)
						.id("MovieGenres")
				}

			}
			
			TabSection("TV Shows") {
				Tab("All TV Shows", systemImage: "tv") {
					GridView(watchables: tvShows, sorting: $sortOrderTvShows, navTitle: "TV Shows")
				}
				Tab("Genres", systemImage: "theatermasks") {
					GenresView(watchables: tvShows, sortOrder: $sortOrderTvShowsGenre)
						.id("TvShowGenres")
				}
			}
			
			let pinned: [any Watchable] = tvShows.filter({ $0.isPinned }) + movies.filter({ $0.isPinned })
			if !pinned.isEmpty {
				TabSection("Pinned") {
					ForEach(pinned, id: \.id) { watchable in
						Tab(watchable.title, systemImage: watchable is Movie ? "movieclapper" : "tv") {
							switch watchable {
								case let tvShow as TvShow:
									TvShowDetailView(tvShow: tvShow)
								case let movie as Movie:
									MovieDetailView(movie: movie)
								default:
									Text("Episodes are not yet supported as Pins.")
							}
						}
					}
				}
			}
		}
		.tabViewStyle(.sidebarAdaptable)
		.fileImporter(isPresented: $commandResource.showImporter, allowedContentTypes: [.mpeg4Movie], allowsMultipleSelection: true, onCompletion: importNewFiles)
		.alert("An Error occurred while importing.", isPresented: $errorMessage.isNotNil()) {
			Button("Ok"){ errorMessage = nil }
		} message: {
			Text(errorMessage ?? "")
		}
		.toolbar {
			ToolbarItem(placement: .primaryAction) {
				Button("Add Item", systemImage: "plus", action: addItem)
					.keyboardShortcut("i", modifiers: .command)
			}
		}
    }
	
	private func importNewFiles(result: Result<[URL], Error>) {
		switch result {
			case .success(let urls):
				urls.forEach { url in
					do {
						try MediaImporter.importFile(data: url, moc: moc, existingTvShows: tvShows)
					} catch(let importError) {
						if errorMessage == nil {
							errorMessage = importError.localizedDescription
						} else {
							errorMessage! += "\n\(importError.localizedDescription)"
						}
					}
				}
					
			case .failure(let error):
				print("Error picking file: \(error.localizedDescription)")
		}
	}
	
	private func addItem() {
		isImporting.toggle()
	}
}
