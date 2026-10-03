//
// Copyright © 2026 MyMedia.
// Licensed under the MIT License.
//

import AwesomeSwiftyComponents
import MyMediaAPI
import SwiftData
import SwiftUI

struct DeveloperSettingsTab: View {

	let dangerSymbol = "exclamationmark.triangle.fill"
	@Binding var settingsTab: SettingsTab
	@Binding var developerMode: Bool

	@State private var showDeletionAlert: Bool = false
	@State private var deleteError: Error?
	@Environment(\.modelContext) private var context
	@Environment(\.openURL) private var openURL
	@Environment(ApiServerManager.self) private var apiServer

	var body: some View {
		Form {
			Section("API Documentation") {
				Button("Open API Documentation", systemImage: "network") {
					openURL(apiServer.localURL.appending(path: "api-docs"))
				}
				.settingDescription("Open the interactive Scalar API reference in your browser.")

				Button("Open DocC Documentation", systemImage: "book.pages") {
					openURL(apiServer.localURL.appending(path: "docs"))
				}
				.settingDescription("Open the web export of the API's DocC documentation.")
			}

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
				.alert("Error while deleting all content", isPresented: $deleteError.isNotNil()) {
					CloseButton { deleteError = nil }
				}
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
		.frame(height: 360)
	}

	func deleteAllContent() {
		do {
			try MetadataUtil.deleteAllContent(context: context)
		} catch {
			deleteError = error
		}
	}
}

#Preview {
	DeveloperSettingsTab(settingsTab: .constant(.developer), developerMode: .constant(true))
		.formStyle(.grouped)
}
