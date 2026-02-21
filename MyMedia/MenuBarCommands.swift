//
//  MenuBarCommands.swift
//  MyMedia
//
//  Created by Jonas Helmer on 12.10.25.
//

import SwiftUI

struct MenuBarCommands: Commands {
	
	let commandResource: CommandResource
	
	@Environment(\.openWindow) private var openWindow
	@AppStorage(PreferenceKeys.useMiniSeries) private var useMiniSeries: Bool = true
	
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
			Link(destination: URL(string: "https://github.com/photangralenphie/MyMedia")!) {
				Label("Show on GitHub", systemImage: "chevron.left.forwardslash.chevron.right")
			}
		}
		
		CommandGroup(after: .sidebar) {
			Menu("Sidebar Entries", systemImage: "checklist") {
				Toggle("Mini-Series", systemImage: "rectangle.stack.badge.play", isOn: $useMiniSeries)
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
