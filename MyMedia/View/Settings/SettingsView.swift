//
//  SettingsView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 12.04.25.
//

import SwiftUI
import AwesomeSwiftyComponents
import AVKit

struct SettingsView: View {

	@AppStorage(PreferenceKeys.useInAppPlayer) private var useInAppPlayer: Bool = true
	@AppStorage(PreferenceKeys.showLanguageFlags) private var showLanguageFlags: Bool = true
	@AppStorage(PreferenceKeys.autoPlay) private var autoPlay: Bool = true
	@AppStorage(PreferenceKeys.playerStyle) private var playerStyle: AVPlayerViewControlsStyle = .floating
	@AppStorage(PreferenceKeys.autoQuit) private var autoQuit: Bool = false
	@AppStorage(PreferenceKeys.downSizeArtwork) private var downSizeArtwork: Bool = true
	@AppStorage(PreferenceKeys.preferShortDescription) private var preferShortDescription: Bool = false
	
	@AppStorage(PreferenceKeys.downSizeArtworkWidth) private var downSizeArtworkWidth: Int = 1000
	@AppStorage(PreferenceKeys.downSizeArtworkHeight) private var downSizeArtworkHeight: Int = 1000
	
	var body: some View {
		TabView {
			Tab("General", systemImage: "gearshape") {
				Form {
					Toggle("Auto Quit", isOn: $autoQuit)
					Text("Automatically quit the app when the last window is closed.")
						.settingDescriptionTextStyle()
				}
			}
			
			Tab("Player", systemImage: "play.rectangle.on.rectangle.fill") {
				Form {
					Toggle("AutoPlay next Episode", isOn: $autoPlay)
					Toggle("Use in-app Player", isOn: $useInAppPlayer)
					
					Divider()
					
					Picker("Player Style", selection: $playerStyle) {
						ForEach(AVPlayerViewControlsStyle.userSelectableStyles, id: \.self) { playerStyle in
							Text(playerStyle.name)
								.tag(playerStyle)
						}
					}
					.frame(width: 180)
				}
			}
			
			Tab("Metadata", systemImage: "list.bullet.rectangle") {
				Form {
					Toggle("Show Languages as Flags", isOn: $showLanguageFlags)
					Toggle("Prefer short Description", isOn: $preferShortDescription)
					Text("If available show the short description of the media item.")
						.settingDescriptionTextStyle()
					
					Divider()
						.padding(.vertical, 3)
					
					ImageDownsizeToggle(isOn: $downSizeArtwork)
					
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
					
					Link(destination: URL(string: "https://github.com/photangralenphie/MyMedia/wiki/Tagging")!) {
						Label("Metadata help", systemImage: "arrow.up.forward.square")
					}
				}
			}
		}
		.frame(width: LayoutConstants.settingsWidth)
		.scenePadding()
	}
}

#Preview {
	SettingsView()
}
