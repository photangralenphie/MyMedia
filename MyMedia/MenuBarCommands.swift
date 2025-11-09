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
	@AppStorage(PreferenceKeys.useMiniSeries) private var useMiniSeries: Bool = false
	
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
		}
		
		CommandGroup(after: .sidebar) {
			Menu("Sidebar Entries", systemImage: "checklist") {
				Toggle("Mini-Series", systemImage: "rectangle.stack.badge.play", isOn: $useMiniSeries)
			}
			Divider()
		}
		
		SidebarCommands()
		ToolbarCommands()
    }
}
