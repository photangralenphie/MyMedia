//
//  Collection.swift
//  MyMedia
//
//  Created by Jonas Helmer on 03.05.25.
//
import SwiftData
import SwiftUI
import Foundation

@Model
public class MediaCollection: IsPinnable
{
	@Attribute(.unique) public var id: UUID = UUID()
	var title: String
	var collectionDescription: String?
	var artwork: Data?
	private var tvShows: [TvShow] = []
	private var movies: [Movie] = []
	private var episodes: [Episode] = []
	
	@Transient var mediaItems: [any MediaItem] {
		(tvShows + movies + episodes).sorted { $0.title < $1.title }
	}
	
	var dateAdded: Date = Date.now
	var isPinned: Bool = false
	
	@Transient var isWatched: Bool {
		tvShows.allSatisfy(\.isWatched)
	}
	
	init(title: String, artwork: Data?) {
		self.title = title
		self.artwork = artwork
	}
	
	func addMediaItem(_ media: any MediaItem) {
		if mediaItems.contains(where: { $0.id == media.id }) {
			return
		}
		
		switch media {
			case let show as TvShow:
				self.tvShows.append(show)
			case let movie as Movie:
				self.movies.append(movie)
			case let episode as Episode:
				self.episodes.append(episode)
			default: break
		}
	}
	
	func isItemInCollection(_ media: any MediaItem) -> Bool {
		switch media {
			case let show as TvShow:
				return self.tvShows.contains(show)
			case let movie as Movie:
				return self.movies.contains(movie)
			case let episode as Episode:
				return self.episodes.contains(episode)
			default: return false
		}
	}
	
	func togglePinned() {
		withAnimation {
			self.isPinned.toggle()
		}
	}
}
