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
								
								if let genre = movie.genre {
									Text("·")
									Text(genre)
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
								
								Text(MetadataUtil.flagEmojis(for: movie.languages))
							}
						}
						.foregroundStyle(.secondary)
						.bold()
					}
					
					Spacer()
					
					PlayButton(watchable: movie)
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
				if let cast = movie.cast {
					VStack(alignment: .leading) {
						Text("CAST")
							.bold()
							.padding(.bottom, 2)
							.font(.caption)
							.foregroundStyle(.secondary)
						Text(cast.joined(separator: "\n"))
					}
					.frame(minWidth: 150)
					
					Spacer()
				}
				
				
				if let directors = movie.directors {
					VStack(alignment: .leading) {
						Text("DIRECTOR")
							.bold()
							.padding(.bottom, 2)
							.font(.caption)
							.foregroundStyle(.secondary)
						Text(directors.joined(separator: "\n"))
						
						if let coDirectors = movie.coDirectors {
							Text("CO-DIRECTOR")
								.bold()
								.padding(.bottom, 2)
								.font(.caption)
								.foregroundStyle(.secondary)
							Text(coDirectors.joined(separator: "\n"))
						}
					}
					.frame(minWidth: 150)
					
					Spacer()
				}
				
				
				if let screenwriters = movie.screenwriters {
					VStack(alignment: .leading) {
						Text("SCREENWRITER")
							.bold()
							.padding(.bottom, 1)
							.font(.caption)
							.foregroundStyle(.secondary)
						Text(screenwriters.joined(separator: "\n"))
					}
					.frame(minWidth: 150)
					
					Spacer()
				}
				
				
				if let producers = movie.producers {
					VStack(alignment: .leading) {
						Text("PRODUCERS")
							.bold()
							.padding(.bottom, 1)
							.font(.caption)
							.foregroundStyle(.secondary)
						Text(producers.joined(separator: "\n"))
						
						if let executiveProducers = movie.executiveProducers {
							Text("EXECUTIVE PRODUCERS")
								.bold()
								.padding(.bottom, 1)
								.font(.caption)
								.foregroundStyle(.secondary)
							
							Text(executiveProducers.joined(separator: "\n"))
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
