//
//  ArtworkView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 10.04.25.
//

import SwiftUI

struct ArtworkView: View {
	
	//let mediaItem: any MediaItem
	let imageData: Data?
	let title: String
	let subtitle: String
	
	var body: some View {
		if let imageData = imageData, let nsImageFromData = NSImage(data: imageData)  {
			ZStack {
				// When not correctly formatted
				Image(nsImage: nsImageFromData)
					.resizable()
					.scaledToFill()
					.frame(width: LayoutConstants.artworkWidth, height: LayoutConstants.artworkHeight)
					.overlay(.ultraThinMaterial)
				
				// "real" image
				Image(nsImage: nsImageFromData)
					.resizable()
					.scaledToFit()
					.frame(width: LayoutConstants.artworkWidth, height: LayoutConstants.artworkHeight)
			}
			.clipShape(.rect(cornerRadius: LayoutConstants.cornerRadius))
		} else {
			Color.accentColor
				.frame(width: LayoutConstants.artworkWidth, height: LayoutConstants.artworkHeight)
				.clipShape(.rect(cornerRadius: LayoutConstants.cornerRadius))
				.overlay(alignment: .center) {
					VStack {
						Text(title)
							.font(.largeTitle)
							.bold()
						Text(subtitle)
							.font(.title)
					}
				}
		}
	}
}
