//
//  DeveloperSettingsTab.swift
//  MyMedia
//
//  Created by Jonas Helmer on 12.04.26.
//

import SwiftUI
import SwiftData

struct DeveloperSettingsTab: View {
	
	let dangerSymbol = "exclamationmark.triangle.fill"
	@Binding var settingsTab: SettingsTab
	@Binding var developerMode: Bool
	
	@State private var showDeletionAlert: Bool = false
	@Environment(\.modelContext) private var context
	
	var body: some View{
		Form {
			Section {
				Button("Delete all Content", systemImage: "trash", role: .destructive) {
					showDeletionAlert.toggle()
				}
				.settingDescription("This will delete all imported Movies, TV Shows and created Collections! The files on your device will not be deleted.")
				.confirmationDialog("Danger!", isPresented: $showDeletionAlert) {
					Button("Cancel", role: .cancel) {
						showDeletionAlert.toggle()
					}
					Button("Yes", role: .destructive) {
						deleteAllContent()
						showDeletionAlert.toggle()
					}
				} message: {
					Text("Do you really want to delete all content?")
				}
				.dialogIcon(Image(systemName: dangerSymbol))
				.tint(.red)
			} header: {
				Label("Danger Area!", systemImage: dangerSymbol)
					.foregroundStyle(.red)
			}

			Section {
				Button("Turn off Developer Mode", systemImage: LayoutConstants.developerModeSymbol) {
					settingsTab = SettingsTab.general
					developerMode.toggle()
				}
				.settingDescription("This will hide this tab.")
			}
		}
		.frame(height: 210)
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

#Preview {
	DeveloperSettingsTab(settingsTab: .constant(.developer), developerMode: .constant(true))
		.formStyle(.grouped)
}
