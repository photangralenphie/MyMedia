//
// Copyright © 2026 MyMedia.
// Licensed under the MIT License.
//

import AVKit
import SwiftUI

struct PlayerSettingsTab: View {

	@AppStorage(PreferenceKeys.autoPlay) private var autoPlay: Bool = true
	@AppStorage(PreferenceKeys.useInAppPlayer) private var useInAppPlayer: Bool = true
	@AppStorage(PreferenceKeys.playerStyle) private var playerStyle: AVPlayerViewControlsStyle = .floating

    var body: some View {
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
    }
}

#Preview {
    PlayerSettingsTab()
}
