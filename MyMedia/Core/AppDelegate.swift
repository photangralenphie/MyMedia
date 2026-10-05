//
// Copyright © 2025 MyMedia.
// Licensed under the MIT License.
//

import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
	func applicationDidFinishLaunching(_: Notification) {
		UserDefaults.standard.register(defaults: [
			PreferenceKeys.downSizeCollectionArtwork: true,
			PreferenceKeys.downSizeArtworkHeight: 1_000,
			PreferenceKeys.downSizeArtworkWidth: 1_000
		])
		MainActor.assumeIsolated {
			LibrarySession.shared.resolveAtLaunch()
		}
	}

	func application(_: NSApplication, open urls: [URL]) {
		MainActor.assumeIsolated {
			if let url = urls.first(where: LibraryPackage.isLibraryFile) {
				LibrarySession.shared.noteOpenedFile(url)
			}
		}
	}

	func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
		UserDefaults.standard.bool(forKey: PreferenceKeys.autoQuit)
	}
}
