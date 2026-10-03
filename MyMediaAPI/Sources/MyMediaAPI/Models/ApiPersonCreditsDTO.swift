//
// Copyright © 2026 MyMedia.
// Licensed under the MIT License.
//

/// Media previews grouped by the role a person performed.
public struct ApiPersonCreditsDTO: Codable, Sendable {
	public let cast: [MediaPreviewDTO]
	public let directors: [MediaPreviewDTO]
	public let coDirectors: [MediaPreviewDTO]
	public let screenwriters: [MediaPreviewDTO]
	public let producers: [MediaPreviewDTO]
	public let executiveProducers: [MediaPreviewDTO]
	public let composer: [MediaPreviewDTO]

	public init(
		cast: [MediaPreviewDTO],
		directors: [MediaPreviewDTO],
		coDirectors: [MediaPreviewDTO],
		screenwriters: [MediaPreviewDTO],
		producers: [MediaPreviewDTO],
		executiveProducers: [MediaPreviewDTO],
		composer: [MediaPreviewDTO]
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
