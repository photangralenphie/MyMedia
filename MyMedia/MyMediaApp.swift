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
		let schema = Schema([ TvShow.self, Movie.self, MediaCollection.self ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
		
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
			fatalError("Could not create ModelContainer: \(error.localizedDescription)")
        }
    }()
	
	private var commandResource = CommandResource.shared
	
	@NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

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
		
		WindowGroup(for: PlayAction.self) { playAction in
			if let playAction = playAction.wrappedValue {
				VideoPlayerView(playAction: playAction, context: sharedModelContainer.mainContext)
					.frame(idealWidth: 960, idealHeight: 540)
					.toolbar(removing: .title)
					.toolbarBackground(.hidden, for: .windowToolbar)
					.ignoresSafeArea(edges: .top)
			}
		}
		.defaultSize(width: 960, height: 540)
		.windowStyle(.hiddenTitleBar)
		.commandsRemoved()
		.defaultLaunchBehavior(.suppressed)
		
		Window("About MyMedia", id: "about") {
			AboutView()
				.toolbar(removing: .title)
				.toolbarBackground(.hidden, for: .windowToolbar)
				.containerBackground(.regularMaterial, for: .window)
				.windowMinimizeBehavior(.disabled)
		}
		.windowResizability(.contentSize)
		.restorationBehavior(.disabled)
		.defaultLaunchBehavior(.suppressed)
		
		Settings {
			SettingsView()
		}
    }
}
