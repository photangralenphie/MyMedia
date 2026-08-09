//
//  MovieDTO.swift
//  MyMedia
//
//  Created by Jonas Helmer on 09.08.26.
//

import SwiftUI

struct MovieDTO {
	let artwork: Data?
	let title: String
	let genre: [String]
	let durationMinutes: Int
	let releaseDate: Date
	let shortDescription: String?
	let longDescription: String?
	let creditNames: CreditsDTO
	let studio: String?
	let hdVideoQuality: HDVideoQuality?
	let rating: String?
	let languages: [String]
	let url: URL
}
