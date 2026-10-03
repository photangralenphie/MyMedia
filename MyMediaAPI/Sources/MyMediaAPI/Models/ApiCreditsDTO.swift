//
// Copyright © 2026 MyMedia.
// Licensed under the MIT License.
//

public struct ApiCreditsDTO: Codable, Sendable {
	public let cast: [String]
	public let directors: [String]
	public let coDirectors: [String]
	public let screenwriters: [String]
	public let producers: [String]
	public let executiveProducers: [String]
	public let composer: String?

	public init() {
		cast = []
		directors = []
		coDirectors = []
		screenwriters = []
		producers = []
		executiveProducers = []
		composer = nil
	}

	public init(
		cast: [String],
		directors: [String],
		coDirectors: [String],
		screenwriters: [String],
		producers: [String],
		executiveProducers: [String],
		composer: String?
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
