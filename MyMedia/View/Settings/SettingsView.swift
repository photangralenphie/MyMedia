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

	// General Tab
	@AppStorage(PreferenceKeys.autoQuit) private var autoQuit: Bool = false
	@AppStorage(PreferenceKeys.playButtonInArtwork) private var playButtonInArtwork: Bool = true
	@AppStorage(PreferenceKeys.useMiniSeries) private var useMiniSeries: Bool = true
	
	// Player Tab
	@AppStorage(PreferenceKeys.autoPlay) private var autoPlay: Bool = true
	@AppStorage(PreferenceKeys.useInAppPlayer) private var useInAppPlayer: Bool = true
	@AppStorage(PreferenceKeys.playerStyle) private var playerStyle: AVPlayerViewControlsStyle = .floating

	// Metadata
	@AppStorage(PreferenceKeys.showLanguageFlags) private var showLanguageFlags: Bool = true
	@AppStorage(PreferenceKeys.preferShortDescription) private var preferShortDescription: Bool = false
	@AppStorage(PreferenceKeys.downSizeArtwork) private var downSizeArtwork: Bool = true
	@AppStorage(PreferenceKeys.downSizeArtworkWidth) private var downSizeArtworkWidth: Int = 1000
	@AppStorage(PreferenceKeys.downSizeArtworkHeight) private var downSizeArtworkHeight: Int = 1000
	
	var body: some View {
		TabView {
			Tab("General", systemImage: "gearshape") {
				Form {
					Section("App Behaviour") {
						Toggle("Auto Quit", isOn: $autoQuit)
							.settingDescription("Automatically quit the app when the last window is closed.")
					}
		
					Section("User Interface") {
						Picker("Play Button", selection: $playButtonInArtwork) {
							Label("In Artwork", systemImage: "play.rectangle")
								.tag(true)
							Label("As separate Button", systemImage: "play.square.fill")
								.tag(false)
						}
						
						Toggle("Mini-Series", isOn: $useMiniSeries)
							.settingDescription("If enabled, a new entry in the sidebar appears which allows to only show Mini-(or Limited) Series.")
					}
				}
				.frame(height: 300)
				.formStyle(.grouped)
			}
			
			Tab("Player", systemImage: "play.rectangle.on.rectangle.fill") {
				Form {
					Toggle("AutoPlay next Episode", isOn: $autoPlay)
					Toggle("Use in-app Player", isOn: $useInAppPlayer)
					
					Picker("Player Style", selection: $playerStyle) {
						ForEach(AVPlayerViewControlsStyle.userSelectableStyles, id: \.self) { playerStyle in
							Text(playerStyle.name)
								.tag(playerStyle)
						}
					}
				}
				.frame(height: 160)
				.formStyle(.grouped)
			}
			
			Tab("Metadata", systemImage: "list.bullet.rectangle") {
				Form {
					Toggle("Show Languages as Flags", isOn: $showLanguageFlags)
					Toggle("Prefer short Description", isOn: $preferShortDescription)
						.settingDescription("If available show the short description of the media item.")
					
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
				.formStyle(.grouped)
			}
		}
		.frame(width: LayoutConstants.settingsWidth)
	}
}

#Preview {
	SettingsView()
}
