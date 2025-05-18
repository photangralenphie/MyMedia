//
//  Enums.swift
//  MyMedia
//
//  Created by Jonas Helmer on 18.05.25.
//

enum BadgeStyle {
	case outlined
	case filled
}

enum SortOption: String, CaseIterable, Identifiable {
	case title = "Title"
	case releaseDate = "Release Date"
	case dateAdded = "Date Added"
	
	var id: Self { return self }
}

enum MediaContext {
	case normal
	case collection(_ collection: MediaCollection)
}
