//
//  TvShowDetailView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 31.03.25.
//

import SwiftUI
import AVKit

struct TvShowDetailView: View {
	
	let tvShow: TvShow
	private let titleAndData: String
	private let episodes: [[Episode]]
	
	@Environment(\.dismiss) private var dismiss

	
	init(tvShow: TvShow) {
		self.tvShow = tvShow
		self.titleAndData = "\(tvShow.title) (\(String(tvShow.year)))"
		
		let groupedEpisodes = Dictionary(grouping: tvShow.episodes, by: { $0.season })
		self.episodes = groupedEpisodes.values
			.map { $0.sorted(by: { $0.episode < $1.episode }) }
			.sorted(by: { $0.first!.season < $1.first!.season })
	}
	
    var body: some View {
		List {
			VStack(alignment: .leading, spacing: 20) {
				HStack(alignment: .bottom, spacing: 20) {
					ArtworkView(mediaItem: tvShow)
					VStack(alignment: .leading, spacing: 5) {
						Text(tvShow.title)
							.font(.largeTitle)
							.bold()
						
						Group {
							Text(String(tvShow.year))
							
							Text("^[\(episodes.count) SEASON](inflect: true) ")
								.bold()
							
							Text(tvShow.networks.joined(separator: ", "))
							
							if !tvShow.genre.isEmpty {
								Text(tvShow.genre.joined(separator: ", "))
							}
						}
						.foregroundStyle(.secondary)
					}
					
					Spacer()
					
					PlayButton(mediaItem: tvShow)
						.keyboardShortcut("p", modifiers: .command)
				}
				
				if let description = tvShow.showDescription {
					Text(description)
						.foregroundStyle(.secondary)
				}
			}
			.listRowSeparator(.hidden)
			
			ForEach(episodes, id: \.first?.season) { season in
				Section {
					ForEach(season, id: \.self) { episode in

						HStack(alignment: .center) {
							if let imageData = episode.artwork, let nsImageFromData = NSImage(data: imageData)  {
								Image(nsImage: nsImageFromData)
									.resizable()
									.scaledToFit()
									.frame(width: 150)
									.clipShape(.rect(cornerRadius: 10))
									.padding(.trailing)
							}
							
							VStack(alignment: .leading, spacing: 5) {
								Text("EPISODE \(episode.episode)")
									.bold()
									.foregroundStyle(.secondary)
									.font(.body)
								Text(episode.title)
									.font(.title2)
								Text(episode.episodeShortDescription ?? "")
									.lineLimit(2)
									.foregroundStyle(.secondary)
							}
							
							Spacer()
							
							Text(MetadataUtil.formatRuntime(minutes: episode.durationMinutes))
							
							PlayButton(mediaItem: episode)
						}
						.padding(.vertical, 5)
						.contextMenu {
							MediaItemActionsView(mediaItem: episode) {}
						}
					}
				} header: {
					Text("Season \(String(season.first!.season))")
						.font(.title2)
						.foregroundStyle(Color.primary)
						.bold()
				}
			}
		}
		.toolbar {
			Menu("Actions") {
				MediaItemActionsView(mediaItem: tvShow, onDelete: popNavigation)
			}
		}
		.navigationTitle(titleAndData)
    }
	
	func popNavigation() {
		dismiss()
	}
}
