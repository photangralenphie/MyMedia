//
//  VideoPlayer.swift
//  MyMedia
//
//  Created by Jonas Helmer on 01.04.25.
//

import SwiftUI
import AVKit

struct VideoPlayerView: View {
	@State private var player: AVPlayer
	
	init(url: URL) {
		self.player = AVPlayer(url: url)
	}
	
	var body: some View {
		VideoPlayer(player: player)
			.edgesIgnoringSafeArea(.all)
			.onAppear {
				player.play()
			}
	}
}
