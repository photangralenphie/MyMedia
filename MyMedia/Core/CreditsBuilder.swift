//
// Copyright © 2026 MyMedia.
// Licensed under the MIT License.
//

import Foundation
import SwiftData

struct CreditsBuilder {
	public static func makeCredits(from names: CreditsDTO, context: ModelContext) throws -> Credits {
		let existingPeople = try context.fetch(FetchDescriptor<Person>())
		var peopleByName = Dictionary(existingPeople.map { (normalizedName($0.name), $0) }) { first, _ in first }
		return makeCredits(from: names, context: context, peopleByName: &peopleByName)
	}

	public static func rebuildCredits(movies movieCredits: [UUID: CreditsDTO], episodes episodeCredits: [UUID: CreditsDTO], context: ModelContext) throws {
		var peopleByName: [String: Person] = [:]

		let people = try context.fetch(FetchDescriptor<Person>())
		let movies = try context.fetch(FetchDescriptor<Movie>())
		let episodes = try context.fetch(FetchDescriptor<Episode>())

		for person in people {
			context.delete(person)
		}

		for movie in movies {
			guard let names = movieCredits[movie.id] else { continue }
			movie.credits = makeCredits(from: names, context: context, peopleByName: &peopleByName)
		}

		for episode in episodes {
			guard let names = episodeCredits[episode.id] else { continue }
			episode.credits = makeCredits(from: names, context: context, peopleByName: &peopleByName)
		}

		try context.save()
	}

	public static func replaceCredits(for item: any HasCredits, with newCredits: Credits, context: ModelContext) {
		let oldCredits = item.credits
		let possiblyOrphanedPeople = oldCredits?.people ?? []
		item.credits = newCredits

		if let oldCredits {
			context.delete(oldCredits)
			deletePeopleWithoutRemainingCredits(possiblyOrphanedPeople, removing: [oldCredits], context: context)
		}
	}

	public static func deletePeopleWithoutRemainingCredits(_ people: [Person], removing removedCredits: [Credits], context: ModelContext) {
		for person in people {
			let hasRemainingCredit = person.allCredits.contains { credits in
				!removedCredits.contains { $0 === credits }
			}
			if !hasRemainingCredit {
				context.delete(person)
			}
		}
	}

	private static func makeCredits(from names: CreditsDTO, context: ModelContext, peopleByName: inout [String: Person]) -> Credits {
		let credits = Credits(
			cast: people(for: names.cast, context: context, peopleByName: &peopleByName),
			directors: people(for: names.directors, context: context, peopleByName: &peopleByName),
			coDirectors: people(for: names.coDirectors, context: context, peopleByName: &peopleByName),
			screenwriters: people(for: names.screenwriters, context: context, peopleByName: &peopleByName),
			producers: people(for: names.producers, context: context, peopleByName: &peopleByName),
			executiveProducers: people(for: names.executiveProducers, context: context, peopleByName: &peopleByName),
			composer: person(for: names.composer, context: context, peopleByName: &peopleByName)
		)
		context.insert(credits)
		return credits
	}

	private static func people(for names: [String], context: ModelContext, peopleByName: inout [String: Person]) -> [Person] {
		var seen: Set<String> = []
		return names.compactMap { name in
			guard let person = person(for: name, context: context, peopleByName: &peopleByName) else {
				return nil
			}
			return seen.insert(normalizedName(person.name)).inserted ? person : nil
		}
	}

	private static func person(for name: String?, context: ModelContext, peopleByName: inout [String: Person]) -> Person? {
		guard let name else { return nil }
		let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !trimmedName.isEmpty else { return nil }

		let key = normalizedName(trimmedName)
		if let existingPerson = peopleByName[key] {
			return existingPerson
		}

		let person = Person(name: trimmedName)
		context.insert(person)
		peopleByName[key] = person
		return person
	}

	private static func normalizedName(_ name: String) -> String {
		name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
	}
}
