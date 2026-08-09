//
//  CreditsDTO.swift
//  MyMedia
//
//  Created by Jonas Helmer on 09.08.26.
//

struct CreditsDTO: Sendable {
	let cast: [String]
	let directors: [String]
	let coDirectors: [String]
	let screenwriters: [String]
	let producers: [String]
	let executiveProducers: [String]
	let composer: String?

	init(
		cast: [String] = [],
		directors: [String] = [],
		coDirectors: [String] = [],
		screenwriters: [String] = [],
		producers: [String] = [],
		executiveProducers: [String] = [],
		composer: String? = nil
	) {
		self.cast = cast
		self.directors = directors
		self.coDirectors = coDirectors
		self.screenwriters = screenwriters
		self.producers = producers
		self.executiveProducers = executiveProducers
		self.composer = composer
	}
}
