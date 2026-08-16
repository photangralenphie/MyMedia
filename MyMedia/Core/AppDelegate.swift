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
	}

	func applicationShouldTerminateAfterLastWindowClosed(_: NSApplication) -> Bool {
		UserDefaults.standard.bool(forKey: PreferenceKeys.autoQuit)
	}
}
