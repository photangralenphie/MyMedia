//
// Copyright © 2025 MyMedia.
// Licensed under the MIT License.
//

import MyMediaAPI
import SwiftData
import SwiftUI

@main
struct MyMediaApp: App {
	private let sharedModelContainer: ModelContainer
	private let apiServer: ApiServerManager

	@NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

	@MainActor
	init() {
		let schema = Schema(versionedSchema: MyMediaSchemaV2.self)

        do {
			let container = try ModelContainer(
				for: schema,
				migrationPlan: MyMediaMigrationPlan.self,
				configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)]
			)
			sharedModelContainer = container
        } catch {
			fatalError("Could not create ModelContainer: \(error.localizedDescription)")
        }

		apiServer = ApiServerManager(repository: SwiftDataMediaApiRepository(modelContainer: sharedModelContainer))
		BookmarkStore.migrateLegacyBookmarksFromUserDefaultsIfNeeded()
	}

	private var commandResource = CommandResource.shared

    var body: some Scene {
        WindowGroup {
			HomeView()
				.environment(commandResource)
				.environment(apiServer)
				.onAppear { NSWindow.allowsAutomaticWindowTabbing = false }
				.task { await apiServer.startIfEnabled() }
				.onReceive(NotificationCenter.default.publisher(for: NSApplication.willTerminateNotification)) { _ in
					try? sharedModelContainer.mainContext.save()
				}
        }
		.defaultSize(width: 1_200, height: 700)
		.modelContainer(sharedModelContainer)
		.commands { MenuBarCommands(commandResource: commandResource) }

		VideoPlayerWindow(context: sharedModelContainer.mainContext)

		AboutWindow()

		Settings {
			SettingsView()
				.modelContainer(sharedModelContainer)
				.environment(apiServer)
		}
    }
}
