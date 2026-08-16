//
// Copyright © 2025 MyMedia.
// Licensed under the MIT License.
//

import SwiftUI

enum SettingsTab: String {
	case general
	case player
	case metadata
	case developer
}

struct SettingsView: View {

	@State private var selectedTab = SettingsTab.general
	@AppStorage(PreferenceKeys.developerMode) private var showDeveloperTab: Bool = false

	var body: some View {
		TabView(selection: $selectedTab.animation()) {
			Tab("General", systemImage: "gearshape", value: SettingsTab.general) {
				GeneralSettingsTab()
			}

			Tab("Player", systemImage: "play.rectangle.on.rectangle.fill", value: SettingsTab.player) {
				PlayerSettingsTab()
			}

			Tab("Metadata", systemImage: "list.bullet.rectangle", value: SettingsTab.metadata) {
				MetadataSettingsTab()
			}

			if showDeveloperTab {
				Tab("Developer", systemImage: LayoutConstants.developerModeSymbol, value: SettingsTab.developer) {
					DeveloperSettingsTab(settingsTab: $selectedTab, developerMode: $showDeveloperTab)
				}
			}
		}
		.frame(width: LayoutConstants.settingsWidth)
		.formStyle(.grouped)
	}
}

#Preview {
	SettingsView()
}
