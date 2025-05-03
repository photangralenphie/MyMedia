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
	var artwork: Data
	var media: [any MediaItem]
	
	var dateAdded: Date = Date.now
	var isFavorite: Bool = false
	var isPinned: Bool = false
	
	var isWatched: Bool {
		media.allSatisfy(\.isWatched)
	}
	
	init(title: String, media: [any MediaItem], artwork: Data) {
		self.title = title
		self.media = media
		self.artwork = artwork
	}
}
