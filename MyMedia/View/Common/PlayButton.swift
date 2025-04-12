//
//  PlayButton.swift
//  MyMedia
//
//  Created by Jonas Helmer on 12.04.25.
//

import SwiftUI
import AwesomeSwiftyComponents

struct PlayButton: View {
	
	let watchable: any Watchable
	
	@AppStorage(PreferenceKeys.useInAppPlayer) private var useInAppPlayer: Bool = true
	@Environment(\.openWindow) private var openWindow
	
    var body: some View {
		Button("Play", systemImage: "play") { play(watchable: watchable) }
			.buttonStyle(iOSBorderedForMacOS())
    }
	
	func play(watchable: any Watchable) {
		if useInAppPlayer {
			openWindow(value: watchable.url)
		} else {
			NSWorkspace.shared.open(watchable.url)
		}
	}
}
