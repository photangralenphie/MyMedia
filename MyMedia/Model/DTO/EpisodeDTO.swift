//
// Copyright © 2026 MyMedia.
// Licensed under the MIT License.
//

import SwiftUI

struct EpisodeDTO {
	let artwork: Data?
	let season: Int
	let episode: Int
	let title: String
	let durationMinutes: Int
	let releaseDate: Date
	let shortDescription: String?
	let longDescription: String?
	let creditNames: CreditsDTO
	let studio: String?
	let network: String?
	let rating: String?
	let languages: [String]
	let url: URL
}
