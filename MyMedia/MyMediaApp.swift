//
// Copyright © 2025 MyMedia.
// Licensed under the MIT License.
//

import MyMediaAPI
import SwiftData
import SwiftUI

@main
@MainActor
struct MyMediaApp: App {
	// Created before the delegate so the Option key is recorded before the open-document event.
	@State private var session = LibrarySession.shared

	@NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

	private var commandResource = CommandResource.shared

	var body: some Scene {
		WindowGroup {
			LibraryRootView()
				.environment(commandResource)
		}
		.defaultSize(width: 1_200, height: 700)
		.commands { MenuBarCommands(commandResource: commandResource) }

		VideoPlayerWindow()

		AboutWindow()

		Settings {
			if let container = session.container, let apiServer = session.apiServer {
				SettingsView()
					.modelContainer(container)
					.environment(apiServer)
			} else {
				ProgressView("Opening Library")
			}
		}
	}
}

private struct LibraryRootView: View {
	@State private var session = LibrarySession.shared

	var body: some View {
		if let container = session.container, let apiServer = session.apiServer {
			Group {
				HomeView()
					.environment(apiServer)
					.onAppear { NSWindow.allowsAutomaticWindowTabbing = false }
					.task { await apiServer.startIfEnabled() }
					.onReceive(NotificationCenter.default.publisher(for: NSApplication.willTerminateNotification)) { _ in
						try? container.mainContext.save()
					}
			}
			.modelContainer(container)
		} else {
			ProgressView("Opening Library")
				.frame(maxWidth: .infinity, maxHeight: .infinity)
		}
	}
}
