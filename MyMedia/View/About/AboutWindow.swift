//
// Copyright © 2026 MyMedia.
// Licensed under the MIT License.
//

import SwiftUI

struct AboutWindow: Scene {
    var body: some Scene {
		Window("About MyMedia", id: "about") {
			AboutView()
				.scenePadding()
				.ignoresSafeArea()
				.frame(width: 420, height: 260)
				.toolbar(removing: .title)
				.toolbarBackground(.hidden, for: .windowToolbar)
				.containerBackground(.regularMaterial, for: .window)
				.windowMinimizeBehavior(.disabled)
		}
		.windowResizability(.contentSize)
		.restorationBehavior(.disabled)
		.defaultLaunchBehavior(.suppressed)
    }
}

#Preview {
	AboutView()
		.scenePadding()
		.ignoresSafeArea()
		.frame(width: 420, height: 260)
		.toolbar(removing: .title)
		.toolbarBackground(.hidden, for: .windowToolbar)
		.containerBackground(.regularMaterial, for: .window)
}
