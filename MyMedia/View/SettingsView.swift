//
//  SettingsView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 12.04.25.
//

import SwiftUI
import AwesomeSwiftyComponents

struct PreferenceKeys {
	public static let useInAppPlayer: String = "useInAppPlayer"
	public static let showLanguageFlags: String = "showLanguageFlags"
	public static let autoPlay: String = "autoPlay"
}

struct SettingsView: View {
	
	@AppStorage(PreferenceKeys.useInAppPlayer) private var useInAppPlayer: Bool = true
	@AppStorage(PreferenceKeys.showLanguageFlags) private var showLanguageFlags: Bool = true
	@AppStorage(PreferenceKeys.autoPlay) private var autoPlay: Bool = true
	
    var body: some View {
		TabView {
			Tab("General", systemImage: "gear") {
				Toggle("AutoPlay next Episode", isOn: $autoPlay)
				Toggle("Use in-app Player", isOn: $useInAppPlayer)
			}
			
			Tab("UI", systemImage: "square.on.square.intersection.dashed") {
				Toggle("Show Languages as Flags", isOn: $showLanguageFlags)
			}
		}
		.scenePadding()
		.frame(minWidth: 300)
    }
}

#Preview {
	SettingsView()
}
