//
// Copyright © 2025 MyMedia.
// Licensed under the MIT License.
//

import SwiftUI

struct LayoutSectionHeader: View {

	var section: String

    var body: some View {
		let sectionHeader = Text(LocalizedStringKey(section))
			.font(.title3)
			.bold()
			.padding(.horizontal)
			.padding(.vertical, 3)
			.frame(maxWidth: .infinity, alignment: .leading)

		if #available(macOS 26.0, *) {
			sectionHeader
				.glassEffect()
		} else {
			sectionHeader
				.background(.regularMaterial)
				.padding(.horizontal, -LayoutConstants.gridSpacing)
		}
    }
}
