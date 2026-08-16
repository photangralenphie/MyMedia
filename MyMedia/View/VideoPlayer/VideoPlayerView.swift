//
// Copyright © 2025 MyMedia.
// Licensed under the MIT License.
//

import AVKit
import SwiftData
import SwiftUI
import SwiftUIIntrospect

struct VideoPlayerView: View {
	let playAction: PlayAction

	@State private var vm: VideoPlayerVm

	@Environment(\.dismiss) private var dismiss

	@AppStorage(PreferenceKeys.autoPlay) private var autoPlay: Bool = true
	@AppStorage(PreferenceKeys.playerStyle) private var playerStyle: AVPlayerViewControlsStyle = .floating

	init(playAction: PlayAction, context: ModelContext) {
		self.playAction = playAction
		_vm = State(initialValue: VideoPlayerVm(context: context))
	}

	var body: some View {
		VideoPlayer(player: vm.player)
			.overlay {
				if vm.showErrorSheet {
					ContentUnavailableView {
						Text("Protected Media")
					} description: {
						Text(vm.errorText)
					} actions: {
						Button("Close Player") { dismiss() }
					}
				}
			}
			.task(id: playAction) {
				vm.setupPlayback(playAction: playAction, autoPlay: autoPlay)
			}
			.onReceive(NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: vm.player.currentItem)) { _ in
				if vm.videoDidFinish() {
					dismiss()
				}
			}
			.onReceive(NotificationCenter.default.publisher(for: .AVPlayerItemTimeJumped, object: vm.player.currentItem)) { _ in
				vm.updateNowPlayingInfo()
			}
			.onDisappear(perform: vm.onDisappear)
			.introspect(.videoPlayer, on: .macOS(.v15, .v26, .v27)) { avPlayerView in
				avPlayerView.allowsPictureInPicturePlayback = true
				avPlayerView.controlsStyle = playerStyle
				avPlayerView.showsSharingServiceButton = true
				avPlayerView.showsTimecodes = true
			}
	}
}
