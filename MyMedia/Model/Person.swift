//
//  Person.swift
//  MyMedia
//
//  Created by Jonas Helmer on 04.03.26.
//

import Foundation
import SwiftData

@Model
final class Person {
	
	@Attribute(.unique)
	var name: String
	var roles: [String] = []

	@Relationship
	var creditedMovies: [Movie] = []
	@Relationship
	var creditedEpisodes: [Episode] = []

	@Transient
	var creditedIn: [any MediaItem] {
		(creditedMovies + creditedEpisodes).sorted { $0.title < $1.title }
	}

	init(name: String) {
		self.name = name
	}

	func addRole(_ role: String) {
		if !roles.contains(role) {
			roles.append(role)
		}
	}

	func addCredit(_ mediaItem: any MediaItem) {
		switch mediaItem {
			case let movie as Movie:
				if !creditedMovies.contains(where: { $0.id == movie.id }) {
					creditedMovies.append(movie)
				}
			case let episode as Episode:
				if !creditedEpisodes.contains(where: { $0.id == episode.id }) {
					creditedEpisodes.append(episode)
				}
			default:
				break
		}
	}
}
