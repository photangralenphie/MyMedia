//
//  Credits.swift
//  MyMedia
//
//  Created by Jonas Helmer on 27.07.26.
//

import SwiftData

// HasCredits must be applies to a class so updates work. AnyObject enforces a class
protocol HasCredits: MediaItem, AnyObject {
	var credits: Credits? { get set }
}

@Model
final class Credits {
	@Relationship(inverse: \Person.castCredits)
	var cast: [Person]
	@Relationship(inverse: \Person.directedCredits)
	var directors: [Person]
	@Relationship(inverse: \Person.coDirectedCredits)
	var coDirectors: [Person]
	@Relationship(inverse: \Person.writtenCredits)
	var screenwriters: [Person]
	@Relationship(inverse: \Person.producedCredits)
	var producers: [Person]
	@Relationship(inverse: \Person.executiveProducedCredits)
	var executiveProducers: [Person]
	@Relationship(inverse: \Person.composedCredits)
	var composer: Person?

	var movie: Movie?
	var episode: Episode?

	@Transient
	var people: [Person] {
		let allCredits = (cast + directors + coDirectors + screenwriters + producers + executiveProducers + [composer].compactMap(\.self))
		return Set(allCredits).sorted()
	}

	init(
		cast: [Person] = [],
		directors: [Person] = [],
		coDirectors: [Person] = [],
		screenwriters: [Person] = [],
		producers: [Person] = [],
		executiveProducers: [Person] = [],
		composer: Person? = nil
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
