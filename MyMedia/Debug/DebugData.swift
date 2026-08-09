//
//  DebugData.swift
//  MyMedia
//
//  Created by Jonas Helmer on 11.04.26.
//

import Foundation

struct DebugData {
	@MainActor
	static var items: [any MediaItem] {
		[
			Movie(
				artwork: nil,
				title: "The Silent Shore",
				genre: ["Thriller", "Mystery"],
				durationMinutes: 108,
				releaseDate: Date(timeIntervalSince1970: 1_709_865_600),
				shortDescription: "A detective investigates the disappearance of a small-town fisherman.",
				longDescription: "In a remote coastal village, Detective Mara Ellison uncovers long-buried secrets as she searches for a missing man whose boat washed ashore without him. The truth may be darker than the waves suggest.",
				credits: credits(
					cast: ["Rebecca Ferguson", "Cillian Murphy", "Ben Whishaw"],
					producers: ["Kathleen Kennedy"],
					executiveProducers: ["David Fincher"],
					directors: ["Denis Villeneuve"],
					screenwriters: ["Phoebe Waller-Bridge"],
					composer: "Ryuichi Sakamoto"
				),
				studio: "Netflix Studios",
				hdVideoQuality: .hd1080p,
				rating: "R",
				languages: ["en", "de"]
			),
			Movie(
				artwork: nil,
				title: "Neon Hearts",
				genre: ["Romance", "Comedy"],
				durationMinutes: 96,
				releaseDate: Date(timeIntervalSince1970: 1_713_523_200),
				shortDescription: "Two rival app developers fall in love during a tech conference.",
				longDescription: "When Sophie and Max, competing startup founders, accidentally get booked in the same hotel room, sparks fly in more ways than one. Between coding sessions and chaos, love finds its algorithm.",
				credits: credits(
					cast: ["Florence Pugh", "Nicholas Hoult"],
					producers: ["Nancy Meyers"],
					executiveProducers: ["Richard Curtis"],
					directors: ["Olivia Wilde"],
					screenwriters: ["Mindy Kaling"],
					composer: "Alexandre Desplat"
				),
				studio: "Universal Pictures",
				hdVideoQuality: .hd1080p,
				rating: "PG",
				languages: ["en", "de"]
			),
			Movie(
				artwork: nil,
				title: "Iron Valleys",
				genre: ["Action", "Adventure"],
				durationMinutes: 132,
				releaseDate: Date(timeIntervalSince1970: 1_702_752_000),
				shortDescription: "A retired soldier defends his home from a corporate mining syndicate.",
				longDescription: "After years of peace in the mountains, veteran Jack Rowan is forced back into battle when a powerful corporation threatens his town. Facing impossible odds, he unites locals in a fight for survival and justice.",
				credits: credits(
					cast: ["Idris Elba", "Michelle Rodriguez", "Pedro Pascal"],
					producers: ["Jerry Bruckheimer"],
					executiveProducers: ["Kathleen Kennedy"],
					directors: ["Antoine Fuqua"],
					screenwriters: ["Taylor Sheridan"],
					composer: "Brian Tyler"
				),
				studio: "Warner Bros.",
				hdVideoQuality: .hd1080p,
				rating: "PG-13",
				languages: ["en", "de"]
			),
			Movie(
				artwork: nil,
				title: "Canvas of Dreams",
				genre: ["Drama"],
				durationMinutes: 118,
				releaseDate: Date(timeIntervalSince1970: 1_707_580_800),
				shortDescription: "An artist struggles to find meaning after losing her sight.",
				longDescription: "When acclaimed painter Lucia Moretti loses her vision in an accident, she must rediscover her passion through touch, sound, and emotion. Her journey challenges the definition of art and beauty itself.",
				credits: credits(
					cast: ["Penélope Cruz", "Timothée Chalamet"],
					producers: ["Luca Guadagnino"],
					executiveProducers: ["Alfonso Cuarón"],
					directors: ["Greta Gerwig"],
					screenwriters: ["Emma Donoghue"],
					composer: "Ludovico Einaudi"
				),
				studio: "A24",
				hdVideoQuality: .hd1080p,
				rating: "PG-13",
				languages: ["en", "de"]
			),
			Movie(
				artwork: nil,
				title: "Quantum Thief",
				genre: ["Science Fiction", "Heist"],
				durationMinutes: 128,
				releaseDate: Date(timeIntervalSince1970: 1_714_905_600),
				shortDescription: "A team of specialists plans the ultimate robbery—inside a quantum network.",
				longDescription: "In the near future, data is currency. A rogue hacker assembles a crew to infiltrate the world’s most secure quantum vault. But as timelines diverge, loyalty and reality begin to crumble.",
				credits: credits(
					cast: ["Daniel Kaluuya", "Zendaya", "Oscar Isaac"],
					producers: ["Simon Kinberg"],
					executiveProducers: ["Christopher Nolan"],
					directors: ["Alex Garland"],
					coDirectors: ["Lana Wachowski"],
					screenwriters: ["Alex Garland"],
					composer: "Trent Reznor & Atticus Ross"
				),
				studio: "20th Century Studios",
				hdVideoQuality: .hd1080p,
				rating: "R",
				languages: ["en", "de"]
			)
		]
	}

	private static func credits(
		cast: [String] = [],
		producers: [String] = [],
		executiveProducers: [String] = [],
		directors: [String] = [],
		coDirectors: [String] = [],
		screenwriters: [String] = [],
		composer: String? = nil
	) -> Credits {
		Credits(
			cast: people(cast),
			directors: people(directors),
			coDirectors: people(coDirectors),
			screenwriters: people(screenwriters),
			producers: people(producers),
			executiveProducers: people(executiveProducers),
			composer: composer.map(Person.init(name:))
		)
	}

	private static func people(_ names: [String]) -> [Person] {
		names.map(Person.init(name:))
	}
}
