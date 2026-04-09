//
//  GridCellView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 22.02.26.
//

import SwiftUI

struct GridCellView: View {
	
	let artwork: Data?
	let artworkSubtitle: String
	
	let title: String
	let subtitle: String?
	
	@State private var height: Double = 0
	
    var body: some View {
		VStack(alignment: .leading) {
			GeometryReader { geometry in
				ArtworkView(imageData: artwork, title: title, subtitle: artworkSubtitle, size: CGSize(width: geometry.size.width, height: geometry.size.width / 1.777))
					.onChange(of: geometry.size.width, initial: true) {
						height = geometry.size.width / 1.777
					}
			}
			.frame(height: height)
			
			Text("\(title) \(artworkSubtitle)")
			
			if let subtitle {
				Text(subtitle)
					.textCase(.uppercase)
					.font(.caption)
					.foregroundStyle(.secondary)
			}
		}
    }
}
