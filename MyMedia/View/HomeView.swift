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
	
	@State private var errorMessage: String?
	@State private var importRange: ClosedRange<Int>?
	@State private var currentImportFile: String?
	
	
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
				let unwatched: [any MediaItem] = tvShows.filter({ !$0.isWatched }) + movies.filter({ !$0.isWatched })
				GridView(mediaItems: unwatched, sorting: $sortOrderUnwatched, navTitle: "Unwatched")
			}
			
			Tab("Favorites", systemImage: "star.fill") {
				let favourites: [any MediaItem] = tvShows.filter({ $0.isFavorite }) + movies.filter({ $0.isFavorite })
				GridView(mediaItems: favourites, sorting: $sortOrderFavorites, navTitle: "Favorites")
			}
			
			Tab("Genres", systemImage: "theatermasks") {
				GenresView(mediaItems: tvShows + movies, sortOrder: $sortOrderGenres)
					.id("CommonGenres")
			}
			
//			Tab("Search", systemImage: "magnifyingglass") {
//				Text("Search")
//					.navigationTitle("Search")
//			}
			
			TabSection("Movies") {
				Tab("All Movies", systemImage: "movieclapper") {
					GridView(mediaItems: movies, sorting: $sortOrderMovies, navTitle: "Movies")
				}
				Tab("Genres", systemImage: "theatermasks") {
					GenresView(mediaItems: movies, sortOrder: $sortOrderMoviesGenre)
						.id("MovieGenres")
				}

			}
			
			TabSection("TV Shows") {
				Tab("All TV Shows", systemImage: "tv") {
					GridView(mediaItems: tvShows, sorting: $sortOrderTvShows, navTitle: "TV Shows")
				}
				Tab("Genres", systemImage: "theatermasks") {
					GenresView(mediaItems: tvShows, sortOrder: $sortOrderTvShowsGenre)
						.id("TvShowGenres")
				}
			}
			
			let pinned: [any MediaItem] = tvShows.filter({ $0.isPinned }) + movies.filter({ $0.isPinned })
			if !pinned.isEmpty {
				TabSection("Pinned") {
					ForEach(pinned, id: \.id) { mediaItem in
						Tab(mediaItem.title, systemImage: mediaItem is Movie ? "movieclapper" : "tv") {
							switch mediaItem {
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
