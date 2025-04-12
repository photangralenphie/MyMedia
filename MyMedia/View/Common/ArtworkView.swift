//
//  ArtworkView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 10.04.25.
//

import SwiftUI

struct ArtworkView: View {
	
	let watchable: any Watchable
	
	private let cornerRadius: CGFloat = 20
	private let imageWidth: CGFloat = 300
	
	var body: some View {
		if let imageData = watchable.artwork, let nsImageFromData = NSImage(data: imageData)  {
			Image(nsImage: nsImageFromData)
				.resizable()
				.scaledToFit()
				.frame(width: imageWidth)
				.clipShape(.rect(cornerRadius: cornerRadius))
		} else {
			Color.accentColor
				.frame(width: imageWidth, height: imageWidth / 2)
				.clipShape(.rect(cornerRadius: cornerRadius))
		}
	}
}
