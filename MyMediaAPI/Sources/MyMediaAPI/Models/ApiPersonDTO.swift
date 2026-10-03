//
// Copyright © 2026 MyMedia.
// Licensed under the MIT License.
//

/// All library metadata associated with one credited person.
public struct ApiPersonDTO: Codable, Sendable {
	public let name: String
	public let roles: [String]
	public let creditedMovies: [MediaPreviewDTO]
	public let creditedEpisodes: [MediaPreviewDTO]
	public let credits: ApiPersonCreditsDTO

	public init(
		name: String,
		roles: [String],
		creditedMovies: [MediaPreviewDTO],
		creditedEpisodes: [MediaPreviewDTO],
		credits: ApiPersonCreditsDTO
	) {
		self.name = name
		self.roles = roles
		self.creditedMovies = creditedMovies
		self.creditedEpisodes = creditedEpisodes
		self.credits = credits
	}
}
