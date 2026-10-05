//
// Copyright © 2026 MyMedia.
// Licensed under the MIT License.
//

import AppKit
import CoreServices
import Foundation
import MyMediaAPI
import Observation
import SwiftData

final class LibraryOpenHandler: NSObject {
	@objc func handle(_ event: NSAppleEventDescriptor, withReply _: NSAppleEventDescriptor) {
		guard let url = LibraryAppleEvent.firstLibraryURL(in: event) else { return }
		MainActor.assumeIsolated {
			LibrarySession.shared.noteOpenedFile(url)
		}
	}
}

@MainActor @Observable
final class LibrarySession {
	static let shared = LibrarySession()

	private let openDocumentHandler = LibraryOpenHandler()
	private var didResolve = false
	private var optionDown = false
	private var pendingFile: URL?
	private var scopedResource: URL?
	private var currentPackage: URL?

	private(set) var container: ModelContainer?
	private(set) var apiServer: ApiServerManager?

	private init() {
		optionDown = NSEvent.modifierFlags.contains(.option)
		NSAppleEventManager.shared().setEventHandler(
			openDocumentHandler,
			andSelector: #selector(LibraryOpenHandler.handle(_:withReply:)),
			forEventClass: AEEventClass(kCoreEventClass),
			andEventID: AEEventID(kAEOpenDocuments)
		)
	}

	func noteOpenedFile(_ url: URL) {
		guard LibraryPackage.isLibraryFile(url) else { return }
		if container != nil {
			offerRelaunch(opening: url)
			return
		}
		if pendingFile == nil {
			pendingFile = url
		}
	}

	func resolveAtLaunch() {
		guard !didResolve else { return }
		didResolve = true
		BookmarkStore.migrateLegacyBookmarksFromUserDefaultsIfNeeded()

		if openPendingFile() { return }
		if optionDown {
			openFromChooser()
			return
		}
		if openRememberedBookmark() { return }
		openBuiltIn()
	}

	private func openPendingFile() -> Bool {
		guard let url = pendingFile ?? LibraryAppleEvent.openedLibraryURL() else { return false }
		pendingFile = nil
		do {
			try openPackage(url, replacingExisting: false)
		} catch {
			presentOpenFailure(error)
			openBuiltIn()
		}
		return true
	}

	private func openRememberedBookmark() -> Bool {
		guard let data = LibraryBookmark.load() else { return false }
		do {
			let url = try LibraryBookmark.url(from: data)
			try openPackage(url, replacingExisting: false)
			return true
		} catch {
			LibraryBookmark.clear()
			presentOpenFailure(error)
			return false
		}
	}

	private func openFromChooser() {
		while true {
			if let url = pendingFile {
				pendingFile = nil
				do {
					try openPackage(url, replacingExisting: false)
					return
				} catch {
					presentOpenFailure(error)
				}
			}

			switch chooseLibrary() {
				case .builtIn:
					LibraryBookmark.clear()
					openBuiltIn()
					return
				case .existing(let url):
					do {
						try openPackage(url, replacingExisting: false)
						return
					} catch {
						presentOpenFailure(error)
					}
				case .created(let url):
					do {
						try openPackage(url, replacingExisting: true)
						return
					} catch {
						presentOpenFailure(error)
					}
				case .cancelled:
					break
			}
		}
	}

	private func openPackage(_ url: URL, replacingExisting: Bool) throws {
		guard LibraryPackage.isLibraryFile(url) else {
			throw LibraryError.message(String(localized: "Choose a MyMedia library."))
		}
		try beginScope(url)

		let container: ModelContainer
		do {
			if replacingExisting {
				try replacePackage(at: url)
			}
			let id = try LibraryPackage.ensureIdentity(in: url)
			try LibrarySettings.useLibrary(id: id)
			container = try Self.makeContainer(storeURL: LibraryPackage.storeURL(in: url))
		} catch {
			LibrarySettings.useBuiltInLibrary()
			endScope()
			throw Self.wrap(error)
		}

		do {
			try LibraryBookmark.write(for: url)
		} catch {
			LibraryBookmark.clear()
			present(
				title: String(localized: "Open Library"),
				message: String(localized: "MyMedia could not remember this library. The built-in library will open on the next launch.")
			)
		}

		self.container = container
		self.apiServer = ApiServerManager(repository: SwiftDataMediaApiRepository(modelContainer: container))
		self.currentPackage = url
	}

	private func openBuiltIn() {
		LibrarySettings.useBuiltInLibrary()
		endScope()
		currentPackage = nil

		let container: ModelContainer
		do {
			// No URL: this is the same store the app already uses.
			container = try Self.makeContainer(storeURL: nil)
		} catch {
			fatalError("Could not create ModelContainer: \(error.localizedDescription)")
		}
		self.container = container
		self.apiServer = ApiServerManager(repository: SwiftDataMediaApiRepository(modelContainer: container))
	}

	private static func makeContainer(storeURL: URL?) throws -> ModelContainer {
		let schema = Schema(versionedSchema: MyMediaSchemaV2.self)
		let configuration = if let storeURL {
			ModelConfiguration(schema: schema, url: storeURL, cloudKitDatabase: .none)
		} else {
			ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
		}
		return try ModelContainer(
			for: schema,
			migrationPlan: MyMediaMigrationPlan.self,
			configurations: [configuration]
		)
	}

	private static func wrap(_ error: any Error) -> LibraryError {
		if let libraryError = error as? LibraryError {
			return libraryError
		}
		return .message(error.localizedDescription)
	}

	private func replacePackage(at url: URL) throws {
		let fm = FileManager.default
		if fm.fileExists(atPath: url.path) {
			try fm.removeItem(at: url)
		}
		try fm.createDirectory(at: url, withIntermediateDirectories: true)
		var packageURL = url
		var resourceValues = URLResourceValues()
		resourceValues.isPackage = true
		try? packageURL.setResourceValues(resourceValues)
	}

	private func beginScope(_ url: URL) throws {
		if start(url) { return }
		let parent = url.deletingLastPathComponent()
		guard parent.standardizedFileURL.path != url.standardizedFileURL.path, start(parent) else {
			throw LibraryError.sandboxAccess
		}
	}

	private func start(_ url: URL) -> Bool {
		guard url.startAccessingSecurityScopedResource() else { return false }
		if scopedResource?.standardizedFileURL.path == url.standardizedFileURL.path {
			url.stopAccessingSecurityScopedResource()
			return true
		}
		scopedResource?.stopAccessingSecurityScopedResource()
		scopedResource = url
		return true
	}

	private func endScope() {
		scopedResource?.stopAccessingSecurityScopedResource()
		scopedResource = nil
	}

	private func offerRelaunch(opening url: URL) {
		if isCurrent(url) { return }
		NSApplication.shared.activate()
		let alert = NSAlert()
		alert.messageText = String(localized: "Open Library")
		alert.informativeText = String(localized: "MyMedia can open one library at a time. Quit and reopen to use this library.")
		alert.addButton(withTitle: String(localized: "Quit and Reopen"))
		alert.addButton(withTitle: String(localized: "Cancel"))
		guard alert.runModal() == .alertFirstButtonReturn else { return }

		do {
			try bookmarkForNextLaunch(url)
		} catch {
			presentOpenFailure(error)
			return
		}
		NSApp.terminate(nil)
	}

	private func bookmarkForNextLaunch(_ url: URL) throws {
		let scoped = try temporaryScope(for: url)
		defer { scoped.stopAccessingSecurityScopedResource() }
		try LibraryBookmark.write(for: url)
	}

	private func temporaryScope(for url: URL) throws -> URL {
		if url.startAccessingSecurityScopedResource() {
			return url
		}
		let parent = url.deletingLastPathComponent()
		guard parent.standardizedFileURL.path != url.standardizedFileURL.path, parent.startAccessingSecurityScopedResource() else {
			throw LibraryError.sandboxAccess
		}
		return parent
	}

	private func isCurrent(_ url: URL) -> Bool {
		guard let currentPackage else { return false }
		return currentPackage.standardizedFileURL.path == url.standardizedFileURL.path
	}

	private func chooseLibrary() -> LibraryPick {
		NSApplication.shared.activate()
		let alert = NSAlert()
		alert.messageText = String(localized: "Choose a Library")
		alert.informativeText = String(localized: "Open an existing MyMedia library, create a new one, or use the built-in library.")
		alert.addButton(withTitle: String(localized: "Open..."))
		alert.addButton(withTitle: String(localized: "New..."))
		alert.addButton(withTitle: String(localized: "Built-in Library"))

		switch alert.runModal() {
			case .alertFirstButtonReturn:
				if let url = pickExistingLibrary() {
					return .existing(url)
				}
				return .cancelled
			case .alertSecondButtonReturn:
				if let url = pickNewLibrary() {
					return .created(url)
				}
				return .cancelled
			case .alertThirdButtonReturn:
				return .builtIn
			default:
				return .cancelled
		}
	}

	private func pickExistingLibrary() -> URL? {
		let panel = NSOpenPanel()
		panel.allowedContentTypes = [.myMediaLibrary]
		panel.allowsOtherFileTypes = false
		panel.allowsMultipleSelection = false
		panel.canChooseFiles = true
		panel.canChooseDirectories = false
		panel.canCreateDirectories = true
		panel.prompt = String(localized: "Open...")
		panel.message = String(localized: "Choose a MyMedia library.")
		guard panel.runModal() == .OK, let url = panel.url else { return nil }
		return url
	}

	private func pickNewLibrary() -> URL? {
		let panel = NSSavePanel()
		panel.allowedContentTypes = [.myMediaLibrary]
		panel.allowsOtherFileTypes = false
		panel.canCreateDirectories = true
		panel.nameFieldStringValue = "Library"
		panel.prompt = String(localized: "Create")
		panel.message = String(localized: "Choose where to save the new library.")
		guard panel.runModal() == .OK, let url = panel.url else { return nil }
		return url
	}

	private func presentOpenFailure(_ error: any Error) {
		present(
			title: String(localized: "Could not open the library"),
			message: error.localizedDescription
		)
	}

	private func present(title: String, message: String) {
		NSApplication.shared.activate()
		let alert = NSAlert()
		alert.messageText = title
		alert.informativeText = message
		alert.runModal()
	}
}

private enum LibraryPick {
	case builtIn
	case existing(URL)
	case created(URL)
	case cancelled
}
