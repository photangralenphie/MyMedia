//
//  Enums.swift
//  MyMedia
//
//  Created by Jonas Helmer on 18.05.25.
//

import SwiftUICore

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
	
	var id: Self { return self }
}

enum MediaContext {
	case normal
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
