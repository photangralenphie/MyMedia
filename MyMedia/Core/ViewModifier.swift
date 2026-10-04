//
// Copyright © 2025 MyMedia.
// Licensed under the MIT License.
//

import SwiftUI

struct MediaItemDraggableModifier: ViewModifier {
	private let mediaItem: any MediaItem

	private let scale: CGFloat
	private let cornerRadius: CGFloat

	init(mediaItem: any MediaItem) {
		let scale: CGFloat = 0.4
		self.mediaItem = mediaItem
		self.scale = scale
		self.cornerRadius = LayoutConstants.cornerRadius * scale
	}

	func body(content: Content) -> some View {
		content
			.draggable(mediaItem.id.uuidString) {
				let dragPreview = VStack(alignment: .leading) {
					ArtworkView(imageData: mediaItem.artwork, title: mediaItem.title, subtitle: "", scale: scale)
					Text("\(mediaItem.title) - (\(String(mediaItem.year)))")
				}
				.padding(5)

				if #available(macOS 26.0, *) {
					dragPreview
						.glassEffect(in: .rect(cornerRadius: cornerRadius, style: .continuous))
						.clipShape(.rect(cornerRadius: cornerRadius, style: .continuous))
				} else {
					dragPreview
						.background(Material.regular)
						.clipShape(.rect(cornerRadius: cornerRadius, style: .continuous))
				}
			}
	}
}

extension View {
	func creditHeadingStyle() -> some View {
		self
			.bold()
			.padding(.bottom, 2)
			.font(.caption)
			.foregroundStyle(.secondary)
	}

	func mediaItemDraggable(mediaItem: any MediaItem) -> some View {
		self.modifier(MediaItemDraggableModifier(mediaItem: mediaItem))
	}

	func settingDescriptionTextStyle() -> some View {
		self
			.font(.footnote)
			.foregroundStyle(.secondary)
	}
}
