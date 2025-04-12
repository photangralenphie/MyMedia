//
//  GridCellView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 31.03.25.
//

import SwiftUI

struct GridCellView: View {
	
	let watchable: any Watchable
	
    var body: some View {
		VStack(alignment: .leading) {
			if let imageData = watchable.artwork, let nsImageFromData = NSImage(data: imageData)  {
				Image(nsImage: nsImageFromData)
					.resizable()
					.scaledToFill()
					.frame(width: 300, height: 150)
					.clipShape(.rect(cornerRadius: 20))
			}
			
			Text(watchable.title) + Text(" (\(String(watchable.year)))")
			
			if let tvShow = watchable as? TvShow {
				Text("^[\(Set(tvShow.episodes.compactMap(\.season)).count) SEASON](inflect: true) - ^[\(tvShow.episodes.count) EPISODE](inflect: true) ")
					.font(.caption)
					.foregroundStyle(.secondary)
			}
		}
    }
}
