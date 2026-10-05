//
// Copyright © 2026 MyMedia.
// Licensed under the MIT License.
//

import SwiftData
import SwiftUI

struct VideoPlayerWindow: Scene {

	var body: some Scene {
		WindowGroup(for: PlayAction.self) { playAction in
			LibraryPlayerWindowContent(playAction: playAction.wrappedValue)
		}
		.defaultSize(width: 960, height: 540)
		.windowStyle(.hiddenTitleBar)
		.commandsRemoved()
		.defaultLaunchBehavior(.suppressed)
	}
}

private struct LibraryPlayerWindowContent: View {
	let playAction: PlayAction?

	@State private var session = LibrarySession.shared

	var body: some View {
		if let playAction, let context = session.container?.mainContext {
			VideoPlayerView(playAction: playAction, context: context)
				.frame(idealWidth: 960, idealHeight: 540)
				.toolbar(removing: .title)
				.toolbarBackground(.hidden, for: .windowToolbar)
				.ignoresSafeArea(edges: .top)
		}
	}
}
