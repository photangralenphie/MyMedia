//
//  AppDelegate.swift
//  MyMedia
//
//  Created by Jonas Helmer on 23.05.25.
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
