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
	
    var body: some View {
		TabView {
			Tab("General", systemImage: "gearshape") {
				Form {
					Toggle("Auto Quit", isOn: $autoQuit)
					Text("Automatically quit the app when the last window is closed.")
						.font(.footnote)
						.foregroundStyle(.secondary)
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
			
			Tab("UI", systemImage: "square.on.square.intersection.dashed") {
				Form {
					Toggle("Show Languages as Flags", isOn: $showLanguageFlags)
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
