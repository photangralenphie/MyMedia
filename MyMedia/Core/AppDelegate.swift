//
//  AppDelegate.swift
//  MyMedia
//
//  Created by Jonas Helmer on 23.05.25.
//

import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		UserDefaults.standard.register(defaults: [
			PreferenceKeys.downSizeCollectionArtwork: true,
			PreferenceKeys.downSizeArtworkHeight: 1000,
			PreferenceKeys.downSizeArtworkWidth: 1000
		])
	}
	
	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		return UserDefaults.standard.bool(forKey: PreferenceKeys.autoQuit)
	}
}
