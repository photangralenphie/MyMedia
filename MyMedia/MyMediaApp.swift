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
        let schema = Schema([ TvShow.self ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            Home()
        }
        .modelContainer(sharedModelContainer)
		
		WindowGroup(for: URL.self) { url in
			if let url = url.wrappedValue {
				VideoPlayerView(url: url)
					.frame(idealWidth: 960, idealHeight: 540)
			}
		}
		.defaultSize(width: 960, height: 540)
		.windowStyle(.hiddenTitleBar)
		.commandsRemoved()
		.defaultLaunchBehavior(.suppressed)
    }
}
