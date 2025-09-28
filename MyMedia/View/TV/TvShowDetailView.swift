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

	@AppStorage(PreferenceKeys.playButtonInArtwork) private var playButtonInArtwork: Bool = false
	
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
					ArtworkView(imageData: tvShow.artwork, title: tvShow.title, subtitle: "(\(String(tvShow.year)))")
						.overlay { if playButtonInArtwork { PlayButtonOverlayView(mediaItem: tvShow) } }
					VStack(alignment: .leading, spacing: 5) {
						Text(tvShow.title)
							.font(.largeTitle)
							.bold()
						
						Group {
							Text(String(tvShow.year))
							
							Text("^[\(episodes.count) Season](inflect: true) ")
								.textCase(.uppercase)
								.bold()
							
							Text(tvShow.networks.joined(separator: ", "))
							
							if !tvShow.genre.isEmpty {
								Text(tvShow.genre.joined(separator: ", "))
							}
						}
						.foregroundStyle(.secondary)
					}
					
					Spacer()
					
					if !playButtonInArtwork {
						PlayButton(mediaItem: tvShow)
							.keyboardShortcut("p", modifiers: .command)
					}
				}
				
				if let description = MetadataUtil.getDescription(mediaItem: tvShow) {
					Text(description)
						.font(.body.leading(.loose))
						.foregroundStyle(.secondary)
				}
			}
			.listRowSeparator(.hidden)
			
			ForEach(episodes, id: \.first?.season) { season in
				Section {
					ForEach(season, id: \.id) { episode in
						NavigationLink {
							EpisodeDetailView(episode: episode, tvShow: tvShow)
						} label: {
							HStack(alignment: .center) {
								if let imageData = episode.artwork, let nsImageFromData = NSImage(data: imageData)  {
									let episodeImage = Image(nsImage: nsImageFromData)
										.resizable()
										.scaledToFit()
										.frame(width: LayoutConstants.artworkWidth / 2)
										.clipShape(.rect(cornerRadius: LayoutConstants.cornerRadius / 2, style: .continuous))
										.overlay {
											if playButtonInArtwork {
												let height = nsImageFromData.size.height * (CGFloat(LayoutConstants.artworkWidth / 2) / nsImageFromData.size.width)
												PlayButtonOverlayView(mediaItem: episode, width: LayoutConstants.artworkWidth / 2, height: height)
											}
										}
									
									if #available(macOS 26.0, *) {
										episodeImage
											.glassEffect(in: .rect(cornerRadius: 10, style: .continuous))
									} else {
										episodeImage
									}
								}
								
								VStack(alignment: .leading, spacing: 5) {
									Text("Episode \(episode.episode)")
										.textCase(.uppercase)
										.bold()
										.foregroundStyle(.secondary)
										.font(.body)
									Text(episode.title)
										.font(.title2)
									Text(episode.episodeShortDescription ?? "")
										.lineLimit(2)
										.font(.body.leading(.loose))
										.foregroundStyle(.secondary)
								}
								.padding(.leading)
								
								Spacer()
								
								Text(MetadataUtil.formatRuntime(minutes: episode.durationMinutes))
								
								if !playButtonInArtwork {
									PlayButton(mediaItem: episode)
								}
							}
							.padding(.vertical, 5)
							.contextMenu {
								MediaItemActionsView(mediaItem: episode, applyShortcuts: false) {}
							}
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
			Menu("Actions", systemImage: "ellipsis.circle") {
				MediaItemActionsView(mediaItem: tvShow, applyShortcuts: true, onDelete: popNavigation)
			}
		}
		.navigationTitle(titleAndData)
    }
	
	func popNavigation() {
		let dismiss = Environment(\.dismiss).wrappedValue
		dismiss()
	}
}
