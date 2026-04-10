//
//  MyMediaApp.swift
//  MyMedia
//
//  Created by Jonas Helmer on 27.03.25.
//

import SwiftUI
import SwiftData

@main
struct MyMediaApp: App {
    var sharedModelContainer: ModelContainer = {
		let schema = Schema(versionedSchema: MyMediaSchemaV2.self)
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
		
        do {
			return try ModelContainer(
				for: schema,
				migrationPlan: MyMediaMigrationPlan.self,
				configurations: [modelConfiguration]
			)
        } catch {
			fatalError("Could not create ModelContainer: \(error.localizedDescription)")
        }
    }()
	
	private var commandResource = CommandResource.shared
	
	@NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	
	init() {
		BookmarkStore.migrateLegacyBookmarksFromUserDefaultsIfNeeded()
	}

    var body: some Scene {
        WindowGroup {
			HomeView()
				.environment(commandResource)
				.onAppear { NSWindow.allowsAutomaticWindowTabbing = false }
				.onReceive(NotificationCenter.default.publisher(for: NSApplication.willTerminateNotification)) { _ in
					try? sharedModelContainer.mainContext.save()
				}
        }
		.defaultSize(width: 1200, height: 700)
		.modelContainer(sharedModelContainer)
		.commands { MenuBarCommands(commandResource: commandResource) }
		
		VideoPlayerWindow(context: sharedModelContainer.mainContext)
		
		AboutWindow()
		
		Settings {
			SettingsView()
		}
    }
}
