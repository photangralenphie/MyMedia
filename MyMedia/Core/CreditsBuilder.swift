//
//  CreditsBuilder.swift
//  MyMedia
//
//  Created by Jonas Helmer on 04.03.26.
//

import Foundation
import SwiftData

struct CreditsBuilder {
	static func rebuildCreditStore(context: ModelContext) throws {
		let existing = try context.fetch(FetchDescriptor<Person>())
		for person in existing {
			context.delete(person)
		}
		
		let movies = try context.fetch(FetchDescriptor<Movie>())
		let episodes = try context.fetch(FetchDescriptor<Episode>())
		let mediaItems: [any MediaItem] = movies + episodes
		
		let _ = buildCredits(from: mediaItems, context: context)
		
		try context.save()
	}

	private static func buildCredits(from mediaItems: [any MediaItem], context: ModelContext) -> [Person] {
		let credits = mediaItems.compactMap { $0 as? any HasCredits }
		var allCredits: [String: Person] = [:]

		for creditItem in credits {
			addCredits(for: creditItem.cast, role: "Cast", creditItem: creditItem, allCredits: &allCredits, context: context)
			addCredits(for: creditItem.coDirectors, role: "Co-Director", creditItem: creditItem, allCredits: &allCredits, context: context)
			addCredits(for: creditItem.directors, role: "Director", creditItem: creditItem, allCredits: &allCredits, context: context)
			addCredits(for: creditItem.executiveProducers, role: "Executive Producer", creditItem: creditItem, allCredits: &allCredits, context: context)
			addCredits(for: creditItem.screenwriters, role: "Screenwriter", creditItem: creditItem, allCredits: &allCredits, context: context)

			if let composer = creditItem.composer {
				addCredits(for: [composer], role: "Composer", creditItem: creditItem, allCredits: &allCredits, context: context)
			}
		}

		return Array(allCredits.values)
	}

	private static func addCredits(
		for names: [String],
		role: String,
		creditItem: any HasCredits,
		allCredits: inout [String: Person],
		context: ModelContext
	) {
		for name in names {
			let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
			guard !trimmedName.isEmpty else { continue }

			let person: Person
			if let existingPerson = allCredits[trimmedName] {
				person = existingPerson
			} else {
				person = Person(name: trimmedName)
				context.insert(person)
				allCredits[trimmedName] = person
			}

			person.addRole(role)
			person.addCredit(creditItem as any MediaItem)
		}
	}
}
