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
	
	let MAX_SETTING_WIDTH: CGFloat = 250
	
	@AppStorage(PreferenceKeys.useInAppPlayer) private var useInAppPlayer: Bool = true
	@AppStorage(PreferenceKeys.showLanguageFlags) private var showLanguageFlags: Bool = true
	@AppStorage(PreferenceKeys.autoPlay) private var autoPlay: Bool = true
	@AppStorage(PreferenceKeys.playerStyle) private var playerStyle: AVPlayerViewControlsStyle = .floating
	
    var body: some View {
		TabView {
			Tab("Player", systemImage: "play.rectangle.on.rectangle.fill") {
				Form {
					Toggle("AutoPlay next Episode", isOn: $autoPlay)
					Toggle("Use in-app Player", isOn: $useInAppPlayer)
					
					Divider()
						.frame(maxWidth: MAX_SETTING_WIDTH)
					
					Picker("Player Style", selection: $playerStyle) {
						ForEach(AVPlayerViewControlsStyle.userSelectableStyles, id: \.self) { playerStyle in
							Text(playerStyle.name)
								.tag(playerStyle)
						}
					}
					.frame(maxWidth: MAX_SETTING_WIDTH)
				}
			}
			
			Tab("UI", systemImage: "square.on.square.intersection.dashed") {
				Form {
					Toggle("Show Languages as Flags", isOn: $showLanguageFlags)
				}
			}
		}
		.scenePadding()
		.frame(minWidth: 300)
    }
}

#Preview {
	SettingsView()
}
