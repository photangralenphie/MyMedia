//
//  SettingsView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 12.04.25.
//

import SwiftUI

struct PreferenceKeys {
	public static let useInAppPlayer: String = "useInAppPlayer"
}

struct SettingsView: View {
	
	@AppStorage(PreferenceKeys.useInAppPlayer) private var useInAppPlayer: Bool = true
	
    var body: some View {
		TabView {
			Tab("General", systemImage: "gear") {
				Toggle("Use in-app Player", isOn: $useInAppPlayer)
			}
		}
		.scenePadding()
		.frame(minWidth: 300)
    }
}

#Preview {
	SettingsView()
}
