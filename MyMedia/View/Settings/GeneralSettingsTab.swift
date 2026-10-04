//
// Copyright © 2026 MyMedia.
// Licensed under the MIT License.
//

import SwiftUI

struct GeneralSettingsTab: View {

	@AppStorage(PreferenceKeys.autoQuit) private var autoQuit: Bool = false
	@AppStorage(PreferenceKeys.playButtonInArtwork) private var playButtonInArtwork: Bool = true
	@AppStorage(PreferenceKeys.useMiniSeries) private var useMiniSeries: Bool = true

    var body: some View {
		Form {
			Section("App Behaviour") {
				Toggle(isOn: $autoQuit) {
					Text("Auto Quit")
					Text("Automatically quit the app when the last window is closed.")
				}
			}

			Section("User Interface") {
				Picker("Play Button", selection: $playButtonInArtwork) {
					Label("In Artwork", systemImage: "play.rectangle")
						.tag(true)

					Label("As separate Button", systemImage: "play.square.fill")
						.tag(false)
				}

				Toggle(isOn: $useMiniSeries) {
					Text("Mini-Series")
					Text("If enabled, a new entry in the sidebar appears which allows to only show Mini-(or Limited) Series.")
				}
			}
		}
		.frame(height: 300)
    }
}

#Preview {
    GeneralSettingsTab()
}
