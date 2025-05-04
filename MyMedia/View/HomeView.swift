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
	@Environment(CommandResource.self) var commandResource
	@Query(sort: \TvShow.title) private var tvShows: [TvShow]
	@Query(sort: \Movie.title) private var movies: [Movie]
	
	@State private var errorMessage: String?
	@State private var importRange: ClosedRange<Int>?
	@State private var currentImportFile: String?
	
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
		
		@Bindable var commandResource = commandResource
		
		TabView(selection: $selectedTab) {
//			Tab("Recent", systemImage: "calendar") {
//				Text("Recent")
//					.navigationTitle("Recent")
//			}
			
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
			VStack(alignment: .leading) {
				if let importRange {
					HStack {
						ProgressView(value: CGFloat(importRange.lowerBound.magnitude), total: CGFloat(importRange.upperBound.magnitude))
							.progressViewStyle(.circular)
							.colorMultiply(.accentColor)
							.frame(height: 50)
							.overlay {
								if importRange.lowerBound.magnitude == importRange.upperBound.magnitude {
									Image(systemName: "checkmark")
								}
							}
						
						VStack(alignment: .leading) {
							Text(importRange.lowerBound.magnitude == importRange.upperBound.magnitude ? "Finished Importing" : "Importing")
							
							if let currentImportFile {
								Text(currentImportFile)
									.font(.footnote)
									.lineLimit(2)
							}
						}
					}
					
					Divider()
				}
				
				Button("Import Media", systemImage: "plus", action: addItem)
					.font(.title)
					.labelStyle(.titleAndIcon)
					.keyboardShortcut("i", modifiers: .command)
			}
		}
		.fileImporter(isPresented: $commandResource.showImporter, allowedContentTypes: [.mpeg4Movie], allowsMultipleSelection: true, onCompletion: importNewFiles)
		.alert("An Error occurred while importing.", isPresented: $errorMessage.isNotNil()) {
			Button("Ok"){ errorMessage = nil }
		} message: {
			Text(errorMessage ?? "")
		}
    }
	
	private func importNewFiles(result: Result<[URL], Error>) {
		switch result {
			case .success(let urls):
				withAnimation { importRange = 0...urls.count }
				
				Task {
					let assembler = MediaImporter(container: moc.container)
					for (index, url) in urls.enumerated() {
						do {
							currentImportFile = url.lastPathComponent
							try await assembler.importFromFile(path: url)
							withAnimation { importRange = (index + 1)...urls.count }
						} catch(let importError) {
							if errorMessage == nil {
								errorMessage = importError.localizedDescription
							} else {
								errorMessage! += "\n\(importError.localizedDescription)"
							}
						}
					}
					
					withAnimation { currentImportFile = nil }
					try? await Task.sleep(nanoseconds: 10_000_000_000)
					withAnimation { importRange = nil }
				}
					
			case .failure(let error):
				print("Error picking file: \(error.localizedDescription)")
		}
	}
	
	private func addItem() {
		commandResource.showImporter.toggle()
	}
}
