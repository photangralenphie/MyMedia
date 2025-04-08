//
//  TVCell.swift
//  MyMedia
//
//  Created by Jonas Helmer on 31.03.25.
//

import SwiftUI

struct TVCell: View {
	
	let tvShow: TvShow
	
    var body: some View {
		VStack(alignment: .leading) {
			if let imageData = tvShow.artwork, let nsImageFromData = NSImage(data: imageData)  {
				Image(nsImage: nsImageFromData)
					.resizable()
					.scaledToFill()
					.frame(width: 300, height: 150)
					.clipShape(.rect(cornerRadius: 20))
			}
			
			Text(tvShow.title) + Text(" (\(String(tvShow.year)))")
			Text("^[\(Set(tvShow.episodes.compactMap(\.season)).count) SEASON](inflect: true) - ^[\(tvShow.episodes.count) EPISODE](inflect: true) ")
				.font(.caption)
				.foregroundStyle(.secondary)
		}
    }
}
//
//#Preview {
//    TVCell()
//}
