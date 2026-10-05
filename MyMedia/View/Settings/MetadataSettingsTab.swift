//
// Copyright © 2026 MyMedia.
// Licensed under the MIT License.
//

import SwiftUI

struct MetadataSettingsTab: View {

	@AppStorage(PreferenceKeys.showLanguageFlags, store: LibrarySettings.store) private var showLanguageFlags: Bool = true
	@AppStorage(PreferenceKeys.preferShortDescription, store: LibrarySettings.store) private var preferShortDescription: Bool = false
	@AppStorage(PreferenceKeys.downSizeArtwork, store: LibrarySettings.store) private var downSizeArtwork: Bool = true
	@AppStorage(PreferenceKeys.downSizeArtworkWidth, store: LibrarySettings.store) private var downSizeArtworkWidth: Int = 1_000
	@AppStorage(PreferenceKeys.downSizeArtworkHeight, store: LibrarySettings.store) private var downSizeArtworkHeight: Int = 1_000

    var body: some View {
		Form {
			Toggle("Show Languages as Flags", isOn: $showLanguageFlags)

			Toggle(isOn: $preferShortDescription) {
				Text("Prefer short Description")
				Text("If available show the short description of the media item.")
			}

			Section("Artwork") {
				ImageDownsizeToggle(isOn: $downSizeArtwork.animation())

				if downSizeArtwork {
					LabeledContent("Max Size:") {
						HStack {
							TextField("Width", value: $downSizeArtworkWidth, format: .number)
								.labelsHidden()
								.frame(width: 50)

							Text("x")

							TextField("Height", value: $downSizeArtworkHeight, format: .number)
								.labelsHidden()
								.frame(width: 50)
						}
					}
				}
			}

			Link(destination: URL(string: "https://github.com/photangralenphie/MyMedia/wiki/Tagging")!) {
				Label("Metadata help", systemImage: "arrow.up.forward.square")
			}
		}
		.frame(height: 310)
    }
}

#Preview {
    MetadataSettingsTab()
}
