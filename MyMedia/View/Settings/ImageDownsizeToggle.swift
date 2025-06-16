//
//  ImageDownsizeToggle.swift
//  MyMedia
//
//  Created by Jonas Helmer on 01.06.25.
//

import SwiftUI

struct ImageDownsizeToggle: View {
	
	@Binding public var isOn: Bool
	
    var body: some View {
		HStack {
			Toggle("Downsize Artwork", isOn: $isOn)
			Image(systemName: "info.circle")
				.help("Importing a larger artwork will consume more memory, and increase loading times.")
		}
    }
}
