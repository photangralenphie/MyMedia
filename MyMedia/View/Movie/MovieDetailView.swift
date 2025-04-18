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
	
	@AppStorage(PreferenceKeys.showLanguageFlags) private var showLanguageFlags: Bool = true
	
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
				HStack(alignment: .center, spacing: 20) {
					ArtworkView(watchable: movie)
					
					VStack(alignment: .leading, spacing: 5) {
						Spacer()
						
						Text(movie.title)
							.font(.largeTitle)
							.bold()
						
						Group {
							HStack {
								Text(movie.releaseDate.formatted(date: .abbreviated, time: .omitted))
								
								if !movie.genre.isEmpty {
									Text("·")
									Text(movie.genre.joined(separator: ", "))
								}
							}
								
							if let studio = movie.studio {
								Text(studio)
							}
							
							Text(MetadataUtil.formatRuntime(minutes: movie.runtime))
							
							HStack {
								if let hdVideoQuality = movie.hdVideoQuality?.badgeTitle {
									BadgeView(text: hdVideoQuality, style: .filled)
								}
								
								if let rating = MetadataUtil.getRating(ratingString: movie.rating) {
									BadgeView(text: rating, style: .outlined)
								}
								
								if showLanguageFlags {
									Text(MetadataUtil.flagEmojis(for: movie.languages))
								} else {
									Text(movie.languages.joined(separator: ", "))
								}
							}
						}
						.foregroundStyle(.secondary)
						.bold()
					}
					
					Spacer()
					
					PlayButton(watchable: movie)
						.keyboardShortcut("p", modifiers: .command)
				}
			}
			.listRowSeparator(.hidden)
			
			if let description = getDescription() {
				VStack(alignment: .leading) {
					Text("SUMMARY")
						.bold()
						.foregroundStyle(.secondary)
						.font(.caption)
						.padding(.bottom, 1)
					
					Text(description)
				}
				.padding(.vertical)
			}
			
			HStack(alignment: .top, spacing: 0) {
				if !movie.cast.isEmpty {
					VStack(alignment: .leading) {
						Text("CAST")
							.bold()
							.padding(.bottom, 2)
							.font(.caption)
							.foregroundStyle(.secondary)
						Text(movie.cast.joined(separator: "\n"))
					}
					.frame(minWidth: 150)
					
					Spacer()
				}
				
				if !movie.directors.isEmpty {
					VStack(alignment: .leading) {
						Text("DIRECTOR")
							.bold()
							.padding(.bottom, 2)
							.font(.caption)
							.foregroundStyle(.secondary)
						Text(movie.directors.joined(separator: "\n"))
						
						if !movie.coDirectors.isEmpty {
							Text("CO-DIRECTOR")
								.bold()
								.padding(.bottom, 2)
								.font(.caption)
								.foregroundStyle(.secondary)
							Text(movie.coDirectors.joined(separator: "\n"))
						}
					}
					.frame(minWidth: 150)
					
					Spacer()
				}
				
				
				if !movie.screenwriters.isEmpty {
					VStack(alignment: .leading) {
						Text("SCREENWRITER")
							.bold()
							.padding(.bottom, 1)
							.font(.caption)
							.foregroundStyle(.secondary)
						Text(movie.screenwriters.joined(separator: "\n"))
					}
					.frame(minWidth: 150)
					
					Spacer()
				}
				
				
				if !movie.producers.isEmpty {
					VStack(alignment: .leading) {
						Text("PRODUCERS")
							.bold()
							.padding(.bottom, 1)
							.font(.caption)
							.foregroundStyle(.secondary)
						Text(movie.producers.joined(separator: "\n"))
						
						if !movie.executiveProducers.isEmpty {
							Text("EXECUTIVE PRODUCERS")
								.bold()
								.padding(.bottom, 1)
								.font(.caption)
								.foregroundStyle(.secondary)
							
							Text(movie.executiveProducers.joined(separator: "\n"))
						}
					}
					.frame(minWidth: 150)
				}
			}
			.padding(.vertical)
		}
		.toolbar {
			WatchableActionsView(watchable: movie, onDelete: popNavigation)
		}
		.navigationTitle(titleAndData)
	}
	
	func popNavigation() {
		dismiss()
	}
	
	func getDescription() -> String? {
		if movie.longDescription != nil {
			return movie.longDescription
		}
		
		if movie.shortDescription != nil {
			return movie.shortDescription
		}
		
		return nil
	}
}
