//
//  AppDelegate.swift
//  MyMedia
//
//  Created by Jonas Helmer on 23.05.25.
//

import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		return UserDefaults.standard.bool(forKey: PreferenceKeys.autoQuit)
	}
}
