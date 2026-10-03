//
// Copyright © 2025 MyMedia.
// Licensed under the MIT License.
//

import SwiftUI

struct MenuBarCommands: Commands {

	let commandResource: CommandResource

	@Environment(\.openWindow) private var openWindow
	@AppStorage(PreferenceKeys.useMiniSeries) private var useMiniSeries: Bool = true
	@AppStorage(InterfaceStateKeys.selectedTab) private var selectedTab: String = Tabs.unwatched.id

    var body: some Commands {
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
			GitHubLink()
		}

		CommandGroup(after: .sidebar) {
			Button("Search", systemImage: Tabs.search.systemImage) {
				selectedTab = Tabs.search.id
			}
			.keyboardShortcut("f", modifiers: .command)

			Menu("Sidebar Entries", systemImage: "checklist") {
				Toggle("Mini-Series", systemImage: "rectangle.stack.badge.play", isOn: $useMiniSeries.animation())
			}
			
			Divider()
		}

		CommandGroup(replacing: .help) {
			Link(destination: URL(string: "https://github.com/photangralenphie/MyMedia/wiki")!) {
				Label("MyMedia Help", systemImage: "lightbulb.led")
			}
			.keyboardShortcut("?", modifiers: .command)
		}

		SidebarCommands()
		ToolbarCommands()
    }
}
