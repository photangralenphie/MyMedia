//
//  ListCellView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 22.02.26.
//

import SwiftUI

struct ListCellView: View {

	let artwork: Data?
	let artworkSubtitle: String

	let title: String
	let subtitle: String?

	@State private var height: Double = 0

	var body: some View {
		HStack {
			ArtworkView(imageData: artwork, title: title, subtitle: artworkSubtitle, scale: 0.6)

			VStack(alignment: .leading) {

				Text(title)
					.font(.title2)
					.bold()
					.padding(.bottom, 1)

				Text(artworkSubtitle)
					.font(.title3)
					.padding(.bottom, 2)

				if let subtitle {
					Text(subtitle)
						.textCase(.uppercase)
						.foregroundStyle(.secondary)
				}
			}
			Spacer()
		}
	}
}
