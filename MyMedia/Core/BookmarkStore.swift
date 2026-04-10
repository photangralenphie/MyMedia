//
//  BookmarkStore.swift
//  MyMedia
//
//  Created by Jonas Helmer on 04.03.26.
//

import Foundation

struct BookmarkStore {
	private static var bookmarks: [String: Data] = loadFromDisk()

	// Queue avoids possible race conditions when reading and writing bookmarks.
	private static let queue = DispatchQueue(label: "MyMedia.BookmarkStore")
	private static let migrationFlag = "didMigrateBookmarksToFile"
	
	private static var bookmarksFileURL: URL = {
		let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
		return appSupport.appending(path: "Bookmarks.plist")
	}()

	/// Gets a bookmark for the provided key.
	static func getBookmark(forKey key: String) -> Data? {
		queue.sync {
			bookmarks[key]
		}
	}

	/// Sets aor deletes bookmark for with the provided key.
	/// If no data is provided, the bookmark is deleted.
	/// - Parameters:
	///   - data: Data for the bookmark. If nil is passed the bookmark will be deleted.
	///   - key: The key of the bookmark.
	static func setBookmark(_ data: Data?, forKey key: String) {
		queue.sync {
			if let data {
				bookmarks[key] = data
			} else {
				bookmarks.removeValue(forKey: key)
			}
			
			saveToDisk(bookmarks)
		}
	}

	static func migrateLegacyBookmarksFromUserDefaultsIfNeeded() {
		guard !UserDefaults.standard.bool(forKey: migrationFlag) else { return }
		
		queue.sync {
			for (key, value) in UserDefaults.standard.dictionaryRepresentation() {
				guard UUID(uuidString: key) != nil else { continue }
				guard let data = value as? Data else { continue }
				guard data.starts(with: Data("book".utf8)) else { continue }

				bookmarks[key] = data
				UserDefaults.standard.removeObject(forKey: key)
			}

			saveToDisk(bookmarks)
			UserDefaults.standard.set(true, forKey: migrationFlag)
		}
	}

	private static func loadFromDisk() -> [String: Data] {
		guard let rawData = try? Data(contentsOf: bookmarksFileURL) else { return [:] }
		guard let plist = try? PropertyListSerialization.propertyList(from: rawData, format: nil) else { return [:] }
		guard let dictionary = plist as? [String: Data] else { return [:] }
		
		return dictionary
	}

	private static func saveToDisk(_ bookmarks: [String: Data]) {
		let directory = bookmarksFileURL.deletingLastPathComponent()
		try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

		guard let encoded = try? PropertyListSerialization.data(fromPropertyList: bookmarks, format: .binary, options: 0) else {
			return
		}
		try? encoded.write(to: bookmarksFileURL, options: [.atomic])
	}
}
