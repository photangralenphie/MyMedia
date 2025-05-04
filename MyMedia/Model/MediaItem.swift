//
//  Item.swift
//  MyMedia
//
//  Created by Jonas Helmer on 27.03.25.
//

import Foundation
import SwiftUI

protocol MediaItem: Identifiable {
	var id: UUID { get }
	var title: String { get }
	var dateAdded: Date { get }
	var artwork: Data? { get }
	
	var year: Int { get }
	
	var isWatched: Bool { get set }
	var isFavorite: Bool { get set }
	var isPinned: Bool { get set }
}

protocol HasGenre: MediaItem {
	var genre: [String] { get }
}

protocol HasCredits: MediaItem {
	var cast: [String] { get }
	var directors: [String] { get }
	var coDirectors: [String] { get }
	var screenwriters: [String] { get }
	var producers: [String] { get }
	var executiveProducers: [String] { get }
	var composer: String? { get }
}

protocol IsWatchable: MediaItem {
	var progressMinutes: Int { get set }
	var durationMinutes: Int { get }
}

extension MediaItem {
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
	
	mutating func toggleWatched() {
		withAnimation {
			self.isWatched.toggle()
		}
	}
	
	mutating func toggleFavorite() {
		withAnimation {
			self.isFavorite.toggle()
		}
	}
	
	mutating func togglePinned() {
		withAnimation {
			self.isPinned.toggle()
		}
	}
	
	func play(useInAppPlayer: Bool, openWindow: OpenWindowAction? = nil) {
		if let openWindow, useInAppPlayer {
			switch self {
				case let tvShow as TvShow :
					openWindow(value: tvShow.findEpisodesToPlay().map(\.persistentModelID))
				case let movie as Movie:
					openWindow(value: [movie.persistentModelID])
				case let episode as Episode:
					openWindow(value: [episode.persistentModelID])
				default: break
			}
		} else {
			switch self {
				case let tvShow as TvShow :
					if let url = tvShow.findEpisodesToPlay().first?.url {
						NSWorkspace.shared.open(url)
					}
				case let isWatchable as any IsWatchable:
					if let url = isWatchable.url {
						NSWorkspace.shared.open(url)
					}
				default: break
			}
		}
	}
}

extension IsWatchable {
	var url: URL? {
		get {
			let bookmarkData = UserDefaults.standard.data(forKey: self.id.uuidString)
			var isStale = false
			if let bookmarkData {
				do {
					let resolvedURL = try URL(
						resolvingBookmarkData: bookmarkData,
						options: [.withSecurityScope],
						relativeTo: nil,
						bookmarkDataIsStale: &isStale
					)
					if isStale {
						let newBookmark = try resolvedURL.bookmarkData(
							options: [.withSecurityScope],
							includingResourceValuesForKeys: nil,
							relativeTo: nil
						)
						UserDefaults.standard.set(newBookmark, forKey: self.id.uuidString)
					}
					return resolvedURL
				} catch {
					print("Failed to resolve bookmark: \(error)")
					return nil
				}
			}
			return nil
		}
		set {
			if let newValue {
				let bookmarkData = try? newValue.bookmarkData(
					options: [.withSecurityScope],
					includingResourceValuesForKeys: nil,
					relativeTo: nil
				)
				UserDefaults.standard.set(bookmarkData, forKey: self.id.uuidString)
			}
		}
	}
	
	func openInSubler() {
		guard let url = self.url else { return }
		let appPath = "/Applications/Subler.app"

		let process = Process()
		process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
		process.arguments = ["-a", appPath, url.path]
		
		do {
			try process.run()
		} catch {
			print("Failed to open file: \(error)")
		}
	}
}
