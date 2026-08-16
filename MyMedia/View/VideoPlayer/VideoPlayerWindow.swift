//
// Copyright © 2026 MyMedia.
// Licensed under the MIT License.
//

import SwiftData
import SwiftUI

struct VideoPlayerWindow: Scene {

	let context: ModelContext

    var body: some Scene {
		WindowGroup(for: PlayAction.self) { playAction in
			if let playAction = playAction.wrappedValue {
				VideoPlayerView(playAction: playAction, context: context)
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
    }
}
