//
//  EpisodeDTO.swift
//  MyMedia
//
//  Created by Jonas Helmer on 09.08.26.
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
