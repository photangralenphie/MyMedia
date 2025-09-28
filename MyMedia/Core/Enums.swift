//
//  Enums.swift
//  MyMedia
//
//  Created by Jonas Helmer on 18.05.25.
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
	
	var title: LocalizedStringKey {
		switch self {
			case .title:
				return LocalizedStringKey("Title")
			case .releaseDate:
				return LocalizedStringKey("Release Date")
			case .dateAdded:
				return LocalizedStringKey("Date Added")
		}
	}
	
	var systemImageName: String {
		switch self {
			case .title:
				return "textformat.characters"
			case .releaseDate:
				return "calendar"
			case .dateAdded:
				return "plus.square.on.square"
		}
	}
	
	var pickerWidth: CGFloat {
		switch self {
			case .title:
				return 70
			default:
				return 55
		}
	}
	
	var id: Self { return self }
}

enum ViewOption: Int, CaseIterable, Identifiable, Codable {
	case grid = 0
	case list = 1
	case detailList = 2
	
	var title: LocalizedStringKey {
		switch self {
			case .grid:
				return LocalizedStringKey("Grid")
			case .list:
				return LocalizedStringKey("List")
			case .detailList:
				return LocalizedStringKey("Detail List")
		}
	}
	
	var symbolName: String {
		switch self {
			case .grid:
				return "square.grid.2x2"
			case .list:
				return "list.bullet"
			case .detailList:
				return "tablecells"
		}
	}
	
	var id: Self { return self }
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
			case .moviePoster:
				return 0
			case .tvPoster:
				return 0
			case .episodeImage:
				return 1
		}
	}
}

enum HDVideoQuality: Int, Codable {
	case sd = 0
	case hd720p = 1
	case hd1080p = 2
	case uhd4k = 3
	
	var badgeTitle: String {
		switch self {
			case .sd: return "SD"
			case .hd720p: return "Standard HD"
			case .hd1080p: return "Full HD"
			case .uhd4k: return "4K"
		}
	}
}

enum ImportError: LocalizedError {
	case fileNotAccessible
	case noMetadataFound(fileName: String)
	case missingMetadata(type: String)
	case unknown(message: String)

	var errorDescription: LocalizedStringKey {
		switch self {
			case .fileNotAccessible: return "Could not access file."
			case .missingMetadata(let type): return metadataError(metadataType: type)
			case .unknown(let message): return "Unknown Error while reading file:\n\n\(message)."
			case .noMetadataFound(let fileName):  return "No metadata found in file:\n\n\(fileName)\n\nPlease add metadata before importing."
		}
	}
	
	var errorCode: Int {
		switch self {
			case .fileNotAccessible: return 4
			case .missingMetadata: return 5
			case .unknown: return 6
			case .noMetadataFound: return 7
		}
	}
	
	private func metadataError(metadataType: String) -> LocalizedStringKey {
		return "No \(metadataType) found in metadata."
	}
}
