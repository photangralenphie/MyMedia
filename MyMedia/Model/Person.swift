//
//  Person.swift
//  MyMedia
//
//  Created by Jonas Helmer on 04.03.26.
//

import Foundation
import SwiftData

@Model
final class Person: Hashable, Comparable {
	@Attribute(.unique)
	var name: String
	var castCredits: [Credits] = []
	var directedCredits: [Credits] = []
	var coDirectedCredits: [Credits] = []
	var writtenCredits: [Credits] = []
	var producedCredits: [Credits] = []
	var executiveProducedCredits: [Credits] = []
	var composedCredits: [Credits] = []

	@Transient
	var roles: [String] {
		var result: [String] = []
		if !castCredits.isEmpty {
			result.append("Cast")
		}
		if !directedCredits.isEmpty {
			result.append("Director")
		}
		if !coDirectedCredits.isEmpty {
			result.append("Co-Director")
		}
		if !writtenCredits.isEmpty {
			result.append("Screenwriter")
		}
		if !producedCredits.isEmpty {
			result.append("Producer")
		}
		if !executiveProducedCredits.isEmpty {
			result.append("Executive Producer")
		}
		if !composedCredits.isEmpty {
			result.append("Composer")
		}
		return result
	}

	@Transient
	var creditedMovies: [Movie] {
		Self.uniqueMediaItems(from: allCredits.compactMap(\.movie))
	}

	@Transient
	var creditedEpisodes: [Episode] {
		Self.uniqueMediaItems(from: allCredits.compactMap(\.episode))
	}

	@Transient
	var creditedIn: [any MediaItem] {
		(creditedMovies + creditedEpisodes).sorted { $0.title < $1.title }
	}

	init(name: String) {
		self.name = name
	}

	@Transient
	var allCredits: [Credits] {
		var result: [Credits] = []
		for group in [
			castCredits,
			directedCredits,
			coDirectedCredits,
			writtenCredits,
			producedCredits,
			executiveProducedCredits,
			composedCredits,
		] {
			for credits in group where !result.contains(where: { $0 === credits }) {
				result.append(credits)
			}
		}
		return result
	}

	private static func uniqueMediaItems<T: MediaItem>(from items: [T]) -> [T] {
		var seen: Set<UUID> = []
		var result: [T] = []

		for item in items where seen.insert(item.id).inserted {
			result.append(item)
		}

		return result
	}
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(name)
	}
	
	static func < (lhs: borrowing Person, rhs: borrowing Person) -> Bool {
		lhs.name < lhs.name
	}
}
