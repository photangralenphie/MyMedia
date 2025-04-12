//
//  ArtworkView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 10.04.25.
//

import SwiftUI

struct ArtworkView: View {
	
	let watchable: any Watchable
	
	var body: some View {
		if let imageData = watchable.artwork, let nsImageFromData = NSImage(data: imageData)  {
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
						Text(watchable.title)
							.font(.largeTitle)
							.bold()
						Text("(\(String(watchable.year)))")
							.font(.title)
					}
				}
		}
	}
}
