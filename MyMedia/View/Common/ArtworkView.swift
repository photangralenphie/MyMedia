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
	
	let cornerRadius: CGFloat
	let size: CGSize
	
	init(imageData: Data?, title: String, subtitle: String, scale: CGFloat = 1.0) {
		self.imageData = imageData
		self.title = title
		self.subtitle = subtitle
		self.cornerRadius = LayoutConstants.cornerRadius * scale
		self.size = CGSize(width: LayoutConstants.artworkWidth * scale, height: LayoutConstants.artworkHeight * scale)
	}
	
	var body: some View {
		if let imageData = imageData, let nsImageFromData = NSImage(data: imageData)  {
			let mainImage = Image(nsImage: nsImageFromData)
				.resizable()
				.scaledToFit()
				.frame(width: size.width, height: size.height)

			let backgroundImage = Image(nsImage: nsImageFromData)
				.resizable()
				.scaledToFill()
				.frame(width: size.width, height: size.height)

			ZStack {
				if #available(macOS 26.0, *) {
					backgroundImage
					mainImage
						.glassEffect(in: .rect(cornerRadius: cornerRadius, style: .continuous))
				} else {
					backgroundImage
						.overlay(.ultraThinMaterial)
					mainImage
				}
			}
			.clipShape(.rect(cornerRadius: cornerRadius, style: .continuous))
		} else {
			Color.accentColor
				.frame(width: size.width, height: size.height)
				.clipShape(.rect(cornerRadius: cornerRadius, style: .continuous))
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
