//
// Copyright © 2026 MyMedia.
// Licensed under the MIT License.
//

import AppKit
import CoreServices
import Foundation
import Synchronization
import UniformTypeIdentifiers

extension UTType {
	static let myMediaLibrary = UTType(exportedAs: LibraryPackage.typeIdentifier, conformingTo: .package)
}

/// A library is a package directory. The built-in library is not one of these;
/// it stays at SwiftData's default Application Support/default.store.
enum LibraryPackage {
	/// Also declared in Info.plist.
	static let typeIdentifier = "com.photagralenphie.mymedia.library"
	static let fileExtension = "mymedialibrary"
	static let storeFileName = "default.store"

	private static let identityFileName = "Library.plist"
	private static let identityKey = "id"

	static func isLibraryFile(_ url: URL) -> Bool {
		url.pathExtension.compare(fileExtension, options: .caseInsensitive) == .orderedSame
	}

	static func storeURL(in package: URL) -> URL {
		package.appending(path: storeFileName)
	}

	static func ensureIdentity(in package: URL) throws -> UUID {
		let plistURL = package.appending(path: identityFileName)
		if let id = readIdentity(at: plistURL) {
			return id
		}
		let id = UUID()
		try writeIdentity(id, to: plistURL)
		return id
	}

	private static func readIdentity(at url: URL) -> UUID? {
		guard let data = try? Data(contentsOf: url) else { return nil }
		guard let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) else { return nil }
		guard let dictionary = plist as? [String: Any] else { return nil }
		guard let idString = dictionary[identityKey] as? String else { return nil }
		return UUID(uuidString: idString)
	}

	private static func writeIdentity(_ id: UUID, to url: URL) throws {
		let plist = [identityKey: id.uuidString]
		let data = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
		try data.write(to: url, options: .atomic)
	}
}

enum LibraryError: LocalizedError {
	case sandboxAccess
	case settingsStore
	case message(String)

	var errorDescription: String? {
		switch self {
			case .sandboxAccess:
				String(localized: "MyMedia could not access the selected library.")
			case .settingsStore:
				String(localized: "MyMedia could not store settings for this library.")
			case .message(let message):
				message
		}
	}
}

/// Metadata and artwork choices that change what a library stores or how that library is shown.
/// The built-in library keeps UserDefaults.standard so existing settings stay where they are.
enum LibrarySettings {
	private static let active = Mutex(UserDefaults.standard)

	static var store: UserDefaults {
		active.withLock { $0 }
	}

	static func useBuiltInLibrary() {
		active.withLock { $0 = .standard }
	}

	static func useLibrary(id: UUID) throws {
		let suiteName = "com.photagralenphie.MyMedia.library.\(id.uuidString)"
		guard let suite = UserDefaults(suiteName: suiteName) else {
			throw LibraryError.settingsStore
		}
		suite.register(defaults: [
			PreferenceKeys.downSizeArtwork: true,
			PreferenceKeys.downSizeArtworkHeight: 1_000,
			PreferenceKeys.downSizeArtworkWidth: 1_000,
			PreferenceKeys.downSizeCollectionArtwork: true,
			PreferenceKeys.preferShortDescription: false,
			PreferenceKeys.showLanguageFlags: true
		])
		active.withLock { $0 = suite }
	}
}

enum LibraryBookmark {
	private static var fileURL: URL {
		FileManager.default
			.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
			.appending(path: "CurrentLibrary.bookmark")
	}

	static func load() -> Data? {
		try? Data(contentsOf: fileURL)
	}

	static func clear() {
		try? FileManager.default.removeItem(at: fileURL)
	}

	static func write(for url: URL) throws {
		let data = try url.bookmarkData(
			options: [.withSecurityScope],
			includingResourceValuesForKeys: nil,
			relativeTo: nil
		)
		try save(data)
	}

	static func url(from data: Data) throws -> URL {
		var isStale = false
		let url = try URL(
			resolvingBookmarkData: data,
			options: [.withSecurityScope],
			relativeTo: nil,
			bookmarkDataIsStale: &isStale
		)
		// A successful open writes a fresh bookmark, which replaces a stale one.
		_ = isStale
		return url
	}

	private static func save(_ data: Data) throws {
		let directory = fileURL.deletingLastPathComponent()
		try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
		try data.write(to: fileURL, options: .atomic)
	}
}

enum LibraryAppleEvent {
	static func openedLibraryURL() -> URL? {
		guard let event = NSAppleEventManager.shared().currentAppleEvent else { return nil }
		return firstLibraryURL(in: event)
	}

	static func firstLibraryURL(in event: NSAppleEventDescriptor) -> URL? {
		guard event.eventClass == AEEventClass(kCoreEventClass) else { return nil }
		guard event.eventID == AEEventID(kAEOpenDocuments) else { return nil }
		guard let direct = event.paramDescriptor(forKeyword: keyDirectObject) else { return nil }
		if let url = libraryURL(from: direct) {
			return url
		}

		let count = direct.numberOfItems
		guard count > 0 else { return nil }
		for index in 1...count {
			guard let item = direct.atIndex(index) else { continue }
			if let url = libraryURL(from: item) {
				return url
			}
		}
		return nil
	}

	private static func libraryURL(from descriptor: NSAppleEventDescriptor) -> URL? {
		guard let url = descriptor.fileURL else { return nil }
		guard LibraryPackage.isLibraryFile(url) else { return nil }
		return url
	}
}
