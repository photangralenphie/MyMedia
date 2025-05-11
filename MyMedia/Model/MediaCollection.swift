//
//  Collection.swift
//  MyMedia
//
//  Created by Jonas Helmer on 03.05.25.
//
import SwiftData
import Foundation

@Model
public class MediaCollection
{
	@Attribute(.unique) public var id: UUID = UUID()
	var title: String
	var collectionDescription: String?
	var artwork: Data?
	private var tvShows: [TvShow] = []
	private var movies: [Movie] = []
	private var episodes: [Episode] = []
	
	var mediaItems: [any MediaItem] {
		(tvShows + movies + episodes).sorted { $0.title < $1.title }
	}
	
	var dateAdded: Date = Date.now
	var isFavorite: Bool = false
	var isPinned: Bool = false
	
	var isWatched: Bool {
		tvShows.allSatisfy(\.isWatched)
	}
	
	init(title: String, artwork: Data?) {
		self.title = title
		self.artwork = artwork
	}
	
	func addMediaItem(_ media: any MediaItem) {
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
}
