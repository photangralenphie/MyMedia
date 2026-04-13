//
//  DeveloperTab.swift
//  MyMedia
//
//  Created by Jonas Helmer on 12.04.26.
//

import SwiftUI
import SwiftData

struct DeveloperTab: View {
	@Binding var settingsTab: SettingsTab
	@Binding var developerMode: Bool
	
	@State private var showDeletionAlert: Bool = false
	@Environment(\.modelContext) private var context
	
	var body: some View{
		Form {
			Button("Delete all Content", systemImage: "trash", role: .destructive) {
				showDeletionAlert.toggle()
			}
			.confirmationDialog("Danger!", isPresented: $showDeletionAlert) {
				Button("Yes") {
					deleteAllContent()
					showDeletionAlert.toggle()
				}
			} message: {
				Text("Do you really want to delete all content?")
			}
			
			Button("Turn off Developer Mode", systemImage: LayoutConstants.developerModeSymbol) {
				settingsTab = SettingsTab.general
				developerMode.toggle()
			}
			.settingDescription("This will hide this tab.")
		}
    }
	
	func deleteAllContent() {
		try? context.delete(model: Movie.self)
		try? context.delete(model: Episode.self)
		try? context.delete(model: TvShow.self)
		try? context.delete(model: MediaCollection.self)
		try? context.delete(model: Person.self)
		try? context.save()
	}
}
