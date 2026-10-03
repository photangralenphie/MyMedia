//
// Copyright © 2025 MyMedia.
// Licensed under the MIT License.
//

import SwiftUI

enum BadgeStyle {
	case outlined
	case filled
}

enum SortOption: Int, CaseIterable, Identifiable, Codable {
	case title = 0
	case releaseDate = 1
	case dateAdded = 2

	var title: String {
		switch self {
			case .title: String(localized: "Title")
			case .releaseDate: String(localized: "Release Date")
			case .dateAdded: String(localized: "Date Added")
		}
	}

	var systemImageName: String {
		switch self {
			case .title: "textformat.characters"
			case .releaseDate: "calendar"
			case .dateAdded: "plus.square.on.square"
		}
	}

	var pickerWidth: CGFloat {
		switch self {
			case .title: 70
			default: 55
		}
	}

	var id: Self { self }
}

enum ViewOption: Int, CaseIterable, Identifiable, Codable {
	case grid = 0
	case list = 1
	case detailList = 2

	var title: String {
		switch self {
			case .grid: String(localized: "Grid")
			case .list: String(localized: "List")
			case .detailList: String(localized: "Detail List")
		}
	}

	var symbolName: String {
		switch self {
			case .grid: "square.grid.2x2"
			case .list: "list.bullet"
			case .detailList: "tablecells"
		}
	}

	var id: Self { self }
}

enum MediaContext {
	case single
	case collection(_ collection: MediaCollection)
}

enum CreditKey: LocalizedStringKey {
	case cast = "Cast"
	case director = "Director"
	case coDirector = "Co-Director"
	case screenwriters = "Screenwriters"
	case producers = "Producers"
	case executiveProducers = "Executive Producers"
	case composer = "Composer"
}

enum ArtworkType {
	case moviePoster
	case tvPoster
	case episodeImage

	var index: Int {
		switch self {
			case .moviePoster: 0
			case .tvPoster: 0
			case .episodeImage: 1
		}
	}
}

enum HDVideoQuality: Int, Codable {
	case sd = 0
	case hd720p = 1
	case hd1080p = 2
	case uhd4k = 3

	var title: String {
		switch self {
			case .sd: "SD"
			case .hd720p: "Standard HD"
			case .hd1080p: "Full HD"
			case .uhd4k: "4K"
		}
	}
}

enum ImportError: LocalizedError {
	case fileNotAccessible
	case noMetadataFound(fileName: String)
	case missingMetadata(type: String)
	case failedToBuildCredits
	case unknown(message: String)

	var errorDescription: LocalizedStringKey {
		switch self {
			case .fileNotAccessible: "Could not access file."
			case .missingMetadata(let type): metadataError(metadataType: type)
			case .unknown(let message): "Unknown Error while reading file:\n\n\(message)."
			case .failedToBuildCredits: "Failed to build credits."
			case .noMetadataFound(let fileName): "No metadata found in file:\n\n\(fileName)\n\nPlease add metadata before importing."
		}
	}

	var errorCode: Int {
		switch self {
			case .fileNotAccessible: 4
			case .missingMetadata: 5
			case .unknown: 6
			case .noMetadataFound: 7
			case .failedToBuildCredits: 8
		}
	}

	private func metadataError(metadataType: String) -> LocalizedStringKey {
		"No \(metadataType) found in metadata."
	}
}
