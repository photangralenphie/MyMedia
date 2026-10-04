//
// Copyright © 2025 MyMedia.
// Licensed under the MIT License.
//

import SwiftUI

struct ImageDownsizeToggle: View {

	@Binding public var isOn: Bool

    var body: some View {
		HStack {
			Toggle("Downsize Artwork", isOn: $isOn)
			Image(systemName: "info.circle")
				.help("Importing a larger artwork will consume more memory, and increases loading times.")
		}
    }
}
