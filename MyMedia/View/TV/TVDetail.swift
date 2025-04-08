//
//  TVDetail.swift
//  MyMedia
//
//  Created by Jonas Helmer on 31.03.25.
//

import SwiftUI
import AVKit

struct TVDetail: View {
	
	let tvShow: TvShow
	private let titleAndData: String
	private let episodes: [[Episode]]
	
	@Environment(\.modelContext) private var moc
	@Environment(\.openWindow) private var openWindow
	
	init(tvShow: TvShow) {
		self.tvShow = tvShow
		self.titleAndData = "\(tvShow.title) (\(String(tvShow.year)))"
		
		let groupedEpisodes = Dictionary(grouping: tvShow.episodes, by: { $0.season })
		self.episodes = groupedEpisodes.values.map { $0.sorted(by: { $0.episode < $1.episode }) }
	}
	
    var body: some View {
		List {
			VStack(spacing: 20) {
				HStack(alignment: .bottom, spacing: 20) {
					if let imageData = tvShow.artwork, let nsImageFromData = NSImage(data: imageData)  {
						Image(nsImage: nsImageFromData)
							.resizable()
							.scaledToFit()
							.frame(width: 300)
							.clipShape(.rect(cornerRadius: 20))
					}
					VStack(alignment: .leading, spacing: 5) {
						Text(tvShow.title)
							.font(.largeTitle)
							.bold()
						
						Group {
							Text(String(tvShow.year))
							
							Text("^[\(episodes.count) SEASON](inflect: true) ")
								.bold()
							
							if let genre = tvShow.genre {
								Text(genre)
							}
						}
						.foregroundStyle(.secondary)
					}
					
					Spacer()
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
							
							Text(formatRuntime(minutes: episode.runtime))
							
							Button("Play"){
								openWindow(value: episode.url)
							}
						}
						.padding(.vertical, 5)
//						Text(episode.releaseDate.description)
//						Text(episode.dateAdded.description)
//						Text(episode.episode.description)
//						Text(episode.season.description)
//
//						Text(episode.episodeLongDescription  ?? "short desc")
//						Text(episode.cast?.description ?? "cast")
//						Text(episode.screenwriters?.description ?? "screenwriters")
//						Text(episode.directors?.description ?? "directors")
//						Text(episode.producers?.description ?? "producers")
//						Text(episode.runtime.description)
//						Text(episode.studio ?? "studio")
//						Text(episode.network ?? "network")
//						Text(episode.rating ?? "rating")
//						Text(episode.languages.description)
					}
				} header: {
					Text("Season \(season.first!.season)")
						.font(.title2)
						.foregroundStyle(Color.primary)
						.bold()
				}
			}
		}
		.toolbar {
			Menu("Actions") {
				Button(tvShow.isWatched ? "Mark Unwatched" : "Mark Watched"){
					tvShow.isWatched.toggle()
				}
				
				Button("Add to Favorites"){
					
				}
				
				Button("Pin"){
					
				}
				
				Divider()
				
				Button("Delete"){
					moc.delete(tvShow)
				}
			}
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
}
