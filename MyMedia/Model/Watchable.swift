//
//  Item.swift
//  MyMedia
//
//  Created by Jonas Helmer on 27.03.25.
//

import Foundation
import SwiftUICore

protocol Watchable: Identifiable {
	var id: UUID { get }
	var title: String { get }
	var dateAdded: Date { get }
	var artwork: Data? { get }
	
	var year: Int { get }
	var url: URL { get }
	
	var isWatched: Bool { get set }
	var isFavorite: Bool { get set }
	var isPinned: Bool { get set }
}

protocol WatchableWithGenre: Watchable {
	var genre: [String] { get }
}

extension Watchable {
	var dateAddedSection: String {
		let calendar = Calendar.current
		let now = Date()

		if calendar.isDateInToday(dateAdded) {
			return "Today"
		} else if let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: now),
				  dateAdded >= oneWeekAgo {
			return "Last Week"
		} else if let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: now),
				  dateAdded >= oneMonthAgo {
			return "Last Month"
		} else if let threeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: now),
				  dateAdded >= threeMonthsAgo {
			return "Last 3 Months"
		} else if let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: now),
				  dateAdded >= oneYearAgo {
			return "Last Year"
		} else {
			return "Older"
		}
	}
}
