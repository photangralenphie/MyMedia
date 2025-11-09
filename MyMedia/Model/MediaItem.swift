//
//  Item.swift
//  MyMedia
//
//  Created by Jonas Helmer on 27.03.25.
//

import Foundation
import SwiftUI
import SwiftData

protocol IsPinnable {
	var id: UUID { get }
	var title: String { get }
	var isPinned: Bool { get set }
}

extension IsPinnable {
	var systemImageName: String {
		switch self {
			case is TvShow:
				return Tabs.tvShows.systemImage
			case is Movie:
				return Tabs.movies.systemImage
			case is MediaCollection:
				return Tabs.collections.systemImage
			default:
				return "questionmark"
		}
	}
}

protocol MediaItem: Identifiable, IsPinnable {
	var id: UUID { get }
	var title: String { get }
	var dateAdded: Date { get }
	var artwork: Data? { get }
	
	var year: Int { get }
	
	var isWatched: Bool { get set }
	var isFavorite: Bool { get set }
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
	
	@MainActor
	func play(playType: PlayType, openWindow: OpenWindowAction) {
		let ids: [PersistentIdentifier] = switch self {
			case let tvShow as TvShow :
				tvShow.findEpisodesToPlay().map(\.persistentModelID)
			case let movie as Movie:
				[movie.persistentModelID]
			case let episode as Episode:
				[episode.persistentModelID]
			default: []
		}
		
		let playAction = PlayAction(identifiers: ids, playType: playType)
		openWindow(value: playAction)
	}
	
	func playWithDefaultPlayer() {
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
					if isStale  {
						if resolvedURL.startAccessingSecurityScopedResource() {
							defer { resolvedURL.stopAccessingSecurityScopedResource() }
							let newBookmark = try resolvedURL.bookmarkData(
								options: [.securityScopeAllowOnlyReadAccess],
								includingResourceValuesForKeys: nil,
								relativeTo: nil
							)
							UserDefaults.standard.set(newBookmark, forKey: self.id.uuidString)
						}
					}
					return resolvedURL
				} catch {
					let watchableTitel = self.title
					Task { @MainActor in
						CommandResource.shared.showError(message: "Failed to resolve bookmark for \(watchableTitel).", title: "Error accessing media file", errorCode: 1);
					}
					return nil
				}
			}
			return nil
		}
		set {
			if let newValue {
				let bookmarkData = try? newValue.bookmarkData(
					options: [.securityScopeAllowOnlyReadAccess],
					includingResourceValuesForKeys: nil,
					relativeTo: nil
				)
				UserDefaults.standard.set(bookmarkData, forKey: self.id.uuidString)
			}
		}
	}
	
	@MainActor
	func openInSubler() {
		guard let url = self.url else { return }
		
		if url.startAccessingSecurityScopedResource() {

			let appPath = "/Applications/Subler.app"

			let process = Process()
			process.executableURL = URL(fileURLWithPath: "/usr/bin/open")
			process.arguments = ["-a", appPath, url.path]
			let pipe = Pipe()
				process.standardError = pipe
			do {
				try process.run()
				let data = pipe.fileHandleForReading.readDataToEndOfFile()
				if let output = String(data: data, encoding: .utf8), !output.isEmpty {
					CommandResource.shared.showError(message: "Failed to open Subler: \(output)", title: "Subler Error", errorCode: 2);
				}
			} catch {
				CommandResource.shared.showError(message: "Failed to open Subler: \(error.localizedDescription)", title: "Subler Error", errorCode: 3);
			}
			url.stopAccessingSecurityScopedResource()
		}
	}
	
	@MainActor
	func openInFinder() {
		guard let url = self.url, url.startAccessingSecurityScopedResource() else { return }
		NSWorkspace.shared.activateFileViewerSelecting([url])
		url.stopAccessingSecurityScopedResource()
	}
}

