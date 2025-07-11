//
//  MyMediaApp.swift
//  MyMedia
//
//  Created by Jonas Helmer on 27.03.25.
//

import SwiftUI
import SwiftData
import AVKit

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
	
	@NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	@State private var commandResource = CommandResource()
	@Environment(\.openWindow) var openWindow

    var body: some Scene {
        WindowGroup {
			HomeView()
				.onReceive(NotificationCenter.default.publisher(for: NSApplication.willTerminateNotification)) { _ in
					try? sharedModelContainer.mainContext.save()
				}
				.environment(commandResource)
        }
		.modelContainer(sharedModelContainer)
		.commands {
			CommandGroup(replacing: .undoRedo) { EmptyView() }
			CommandGroup(replacing: .systemServices) { EmptyView() }
			CommandGroup(replacing: .pasteboard) { EmptyView() }
			CommandGroup(replacing: .importExport) {
				Button("Import Files", systemImage: "document.badge.plus") { commandResource.showFileImporter.toggle() }
					.keyboardShortcut("i", modifiers: .command)
					.labelStyle(.titleAndIcon)
				Button("Import Directory", systemImage: "folder.badge.plus") { commandResource.showDirectoryImporter.toggle() }
					.keyboardShortcut("i", modifiers: [.command, .shift])
					.labelStyle(.titleAndIcon)
			}
			CommandGroup(replacing: .appInfo) {
				Button("About", systemImage: "info.circle") { openWindow(id: "about") }
			}
		}
		
		WindowGroup(for: [PersistentIdentifier].self) { ids in
			if let ids = ids.wrappedValue {
				VideoPlayerView(ids: ids, context: sharedModelContainer.mainContext)
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
		
		Settings {
			SettingsView()
		}
    }
}
