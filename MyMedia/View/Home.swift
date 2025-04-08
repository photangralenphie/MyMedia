//
//  Home.swift
//  MyMedia
//
//  Created by Jonas Helmer on 31.03.25.
//

import SwiftUI
import SwiftData

struct Home: View {
	
	@Environment(\.modelContext) private var moc
	@Query private var tvShows: [TvShow]
	@State private var isImporting: Bool = false
	@State private var error: Error?
	
    var body: some View {
		TabView {
			Tab("Recent", systemImage: "calendar") {
				Text("Recent")
					.navigationTitle("Recent")
			}
			
			Tab("Unwatched", systemImage: "eye.slash") {
				Text("Unwatched")
					.navigationTitle("Unwatched")
			}
			
			Tab("Favorites", systemImage: "star.fill") {
				Text("Favorites")
					.navigationTitle("Favorites")
			}
			
			Tab("Search", systemImage: "magnifyingglass") {
				Text("Search")
					.navigationTitle("Search")
			}
			
			TabSection("Movies") {
				Tab("All Movies", systemImage: "movieclapper") {
					Text("All Movies")
						.navigationTitle("All Movies")
				}
				Tab("Genres", systemImage: "theatermasks") {
					Text("Genres")
						.navigationTitle("Genres")
				}

			}
			
			TabSection("TV Shows") {
				Tab("All TV Shows", systemImage: "tv") {
					TVGrid(tvShows: tvShows)
				}
				Tab("Genres", systemImage: "theatermasks") {
					Text("Genres")
						.navigationTitle("Genres")
				}
			}
			
			TabSection("Pinned") {
				Tab("Show 1", systemImage: "tv") {
					Text("Show 1")
						.navigationTitle("Show 1")
				}
				Tab("Movie 1", systemImage: "movieclapper") {
					Text("Movie 1")
						.navigationTitle("Movie 1")
				}
				Tab("Show 2", systemImage: "tv") {
					Text("Show 2")
						.navigationTitle("Show 2")
				}
				Tab("Movie 2", systemImage: "movieclapper") {
					Text("Movie 2")
						.navigationTitle("Movie 2")
				}
			}
		}
		.tabViewStyle(.sidebarAdaptable)
		.fileImporter(isPresented: $isImporting, allowedContentTypes: [.mpeg4Movie], allowsMultipleSelection: true, onCompletion: importNewFiles)
		.alert("An Error occurred while importing.", isPresented: $error.isNotNil()) {
			Button("Ok"){ error = nil }
		}
		.toolbar {
			ToolbarItem(placement: .primaryAction) {
				Button(action: addItem) {
					Label("Add Item", systemImage: "plus")
				}
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
					error = importError
				}
			case .failure(let error):
				print("Error picking file: \(error.localizedDescription)")
		}
	}
	
	private func addItem() {
		isImporting.toggle()
	}
}

extension Binding {
	func isNotNil<T>() -> Binding<Bool> where Value == T? {
		Binding<Bool>(
			get: { self.wrappedValue != nil },
			set: { newValue in
				if !newValue { self.wrappedValue = nil }
			}
		)
	}
}


#Preview {
    Home()
		.modelContainer(for: TvShow.self, inMemory: true)
}
