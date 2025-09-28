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
	@AppStorage(PreferenceKeys.playButtonInArtwork) private var playButtonInArtwork: Bool = true
	
	@Environment(\.modelContext) private var moc
	@Environment(\.dismiss) private var dismiss
	
	init(movie: Movie) {
		self.movie = movie
		self.titleAndData = "\(movie.title) (\(String(movie.year)))"
	}
	
	var body: some View {
		List {
			VStack(alignment: .leading, spacing: 20) {
				HStack(alignment: .center, spacing: 20) {
					ArtworkView(imageData: movie.artwork, title: movie.title, subtitle: "(\(String(movie.year)))")
						.overlay { if playButtonInArtwork { PlayButtonOverlayView(mediaItem: movie) } }
					
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
							
							Text(MetadataUtil.formatRuntime(minutes: movie.durationMinutes))
							
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
					
					if !playButtonInArtwork {
						PlayButton(mediaItem: movie)
							.keyboardShortcut("p", modifiers: .command)
					}
				}
			}
			.listRowSeparator(.hidden)
			
			
			if let description = MetadataUtil.getDescription(mediaItem: movie) {
				VStack(alignment: .leading) {
					Text("Summary")
						.textCase(.uppercase)
						.bold()
						.foregroundStyle(.secondary)
						.font(.caption)
						.padding(.bottom, 1)
					
					Text(description)
						.font(.body.leading(.loose))
				}
				.padding(.vertical)
			}
			
			CreditsView(hasCredits: movie)
		}
		.toolbar {
			Menu("Actions", systemImage: "ellipsis.circle") {
				MediaItemActionsView(mediaItem: movie, applyShortcuts: true, onDelete: popNavigation)
			}
		}
		.navigationTitle(titleAndData)
	}
	
	func popNavigation() {
		dismiss()
	}
}
