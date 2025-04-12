//
//  Item.swift
//  MyMedia
//
//  Created by Jonas Helmer on 27.03.25.
//

import Foundation

protocol Watchable: Identifiable {
	var id: UUID { get }
	var title: String { get }
	var dateAdded: Date { get }
	var artwork: Data? { get }
	
	var year: Int { get }
	var url: URL { get }
	
	var isWatched: Bool { get set }
	var isFavorite: Bool { get set }
	var isPinned: Bool { get set }
	
}
