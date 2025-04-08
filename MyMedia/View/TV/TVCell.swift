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
		VStack {
			if let imageData = tvShow.artwork, let nsImageFromData = NSImage(data: imageData)  {
				Image(nsImage: nsImageFromData)
					.resizable()
					.scaledToFit()
					.frame(width: 300, height: 150)
					.clipShape(.rect(cornerRadius: 20))
			}
			
			Text(tvShow.title) + Text(" (\(String(tvShow.year)))")
		}
    }
}
//
//#Preview {
//    TVCell()
//}
