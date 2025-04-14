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
	@Query private var tvShows: [TvShow]
	@Query private var movies: [Movie]
	@State private var isImporting: Bool = false
	@State private var errorMessage: Error?
	
    var body: some View {
		
		@Bindable var commandResource = commandResource
		
		TabView {
			Tab("Recent", systemImage: "calendar") {
				Text("Recent")
					.navigationTitle("Recent")
			}
			
			Tab("Unwatched", systemImage: "eye.slash") {
				let unwatched: [any Watchable] = tvShows.filter({ !$0.isWatched }) + movies.filter({ !$0.isWatched })
				GridView(watchable: unwatched, navTitle: "Unwatched")
			}
			
			Tab("Favorites", systemImage: "star.fill") {
				let favorites: [any Watchable] = tvShows.filter({ $0.isFavorite }) + movies.filter({ $0.isFavorite })
				GridView(watchable: favorites, navTitle: "Favorites")
			}
			
			Tab("Search", systemImage: "magnifyingglass") {
				Text("Search")
					.navigationTitle("Search")
			}
			
			TabSection("Movies") {
				Tab("All Movies", systemImage: "movieclapper") {
					GridView(watchable: movies, navTitle: "Movies")
				}
				Tab("Genres", systemImage: "theatermasks") {
					Text("Genres")
						.navigationTitle("Genres")
				}

			}
			
			TabSection("TV Shows") {
				Tab("All TV Shows", systemImage: "tv") {
					GridView(watchable: tvShows, navTitle: "TV Shows")
				}
				Tab("Genres", systemImage: "theatermasks") {
					Text("Genres")
						.navigationTitle("Genres")
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
//		.alert("An Error occurred while importing.", isPresented: $errorMessage.isNotNil()) {
//			Button("Ok"){ errorMessage = nil }
//		} message: {
//			Text(errorMessage!.localizedDescription)
//		}
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
				do {
					try urls.forEach { url in
						try MediaImporter.importFile(data: url, moc: moc, existingTvShows: tvShows)
					}
					
				} catch(let importError) {
					errorMessage = importError
				}
			case .failure(let error):
				print("Error picking file: \(error.localizedDescription)")
		}
	}
	
	private func addItem() {
		isImporting.toggle()
	}
}
