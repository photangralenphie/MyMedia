//
//  MovieDetailView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 10.04.25.
//

import SwiftUI

struct MovieDetailView: View {
	
	let movie: Movie
	private let titleAndData: String
	
	@Environment(\.modelContext) private var moc
	@Environment(\.openWindow) private var openWindow
	@Environment(\.dismiss) private var dismiss
	
	init(movie: Movie) {
		self.movie = movie
		self.titleAndData = "\(movie.title) (\(String(movie.year)))"
	}
	
	var body: some View {
		List {
			VStack(alignment: .leading, spacing: 20) {
				HStack(alignment: .bottom, spacing: 20) {
					ArtworkView(watchable: movie)
					VStack(alignment: .leading, spacing: 5) {
						Text(movie.title)
							.font(.largeTitle)
							.bold()
						
						Group {
							Text(String(movie.year))
							
							if let genre = movie.genre {
								Text(genre)
							}
						}
						.foregroundStyle(.secondary)
					}
					
					Spacer()
				}
				
				if let description = movie.longDescription {
					Text(description)
						.foregroundStyle(.secondary)
				}
			}
			.listRowSeparator(.hidden)
		}
		.toolbar {
			WatchableActionsView(watchable: movie, onDelete: popNavigation)
		}
		.navigationTitle(titleAndData)
	}
	
	func formatRuntime(minutes: Int) -> String {
		let hours = minutes / 60
		let mins = minutes % 60
		
		if hours > 0 && mins > 0 {
			return "\(hours) hr, \(mins) min"
		} else if hours > 0 {
			return "\(hours) hr"
		} else {
			return "\(mins) min"
		}
	}
	
	func popNavigation() {
		dismiss()
	}
}
