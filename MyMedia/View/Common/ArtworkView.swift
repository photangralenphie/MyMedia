//
//  ArtworkView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 10.04.25.
//

import SwiftUI

struct ArtworkView: View {
	
	let imageData: Data?
	let title: String
	let subtitle: String
	var scale: CGFloat = 1.0
	
	var body: some View {
		if let imageData = imageData, let nsImageFromData = NSImage(data: imageData)  {
			ZStack {
				// When not correctly formatted
				Image(nsImage: nsImageFromData)
					.resizable()
					.scaledToFill()
					.frame(width: LayoutConstants.artworkWidth * scale, height: LayoutConstants.artworkHeight * scale)
					.overlay(.ultraThinMaterial)
				
				// "real" image
				Image(nsImage: nsImageFromData)
					.resizable()
					.scaledToFit()
					.frame(width: LayoutConstants.artworkWidth * scale, height: LayoutConstants.artworkHeight * scale)
			}
			.clipShape(.rect(cornerRadius: LayoutConstants.cornerRadius * scale))
		} else {
			Color.accentColor
				.frame(width: LayoutConstants.artworkWidth * scale, height: LayoutConstants.artworkHeight * scale)
				.clipShape(.rect(cornerRadius: LayoutConstants.cornerRadius * scale))
				.overlay(alignment: .center) {
					VStack {
						Text(LocalizedStringKey(title))
							.font(.largeTitle)
							.bold()
						Text(LocalizedStringKey(subtitle))
							.font(.title)
					}
				}
		}
	}
}
