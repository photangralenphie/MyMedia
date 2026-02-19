//
//  SearchVm.swift
//  MyMedia
//
//  Created by Jonas Helmer on 05.10.25.
//

import Foundation
import SwiftUI

@MainActor
@Observable
class SearchVm {
	@ObservationIgnored
	private var mediaItems: [any MediaItem]
	
	var searchText: String = ""
	var searchScope: SearchScope = .all
	
	var navigationTitle: LocalizedStringKey {
		if searchText.isEmpty {
			return "Search"
		} else {
			return "Results for: \(searchText)"
		}
	}
	
	var mediaItemsFilteredByTitle: [any MediaItem] {
		mediaItems.filter {
			return matchesQuery($0.title)
		}
	}
	
	var mediaItemsFilteredByDescription: [any MediaItem] {
		mediaItems.filter {
			if let description = MetadataUtil.getDescription(mediaItem: $0) {
				return matchesQuery(description)
			}
			return false
		}
	}
	
//	var mediaItemsFilteredByAll: [(any HasCredits, String)] {
//		var result: [(any HasCredits, String)] = []
//		mediaItems.forEach { mediaItem in
//			if let hasCredits = mediaItem as? any HasCredits {
//				hasCredits.cast
//			}
//		}
//	}
	
	init(mediaItems: [any MediaItem]) {
		self.mediaItems = mediaItems
	}
	
	func search(_ searchText: String) {
		self.searchText = searchText
	}
	
	func matchesQuery(_ text: String) -> Bool {
		return text.range(of: searchText, options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive]) != nil
	}
	
	
	static func highlightResult(_ text: String, matching query: String) -> AttributedString {
		var attributedText = AttributedString(text)
		let tokens = query.split(whereSeparator: \.isWhitespace).map(String.init)
		guard !tokens.isEmpty else { return attributedText }

		for token in tokens {
			var searchRange = text.startIndex..<text.endIndex
			while let textRange = text.range(of: token,
										   options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive],
									 range: searchRange,
									 locale: .current) {
				let attributedStringRange = Range(textRange, in: attributedText)
				if let attributedStringRange  {
					attributedText[attributedStringRange].font = .body.bold()
					attributedText[attributedStringRange].backgroundColor = Color.accentColor
				}
				searchRange = textRange.upperBound..<text.endIndex
			}
		}
		return attributedText
	}
}
