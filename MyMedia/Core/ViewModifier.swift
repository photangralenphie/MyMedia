//
//  ViewModifier.swift
//  MyMedia
//
//  Created by Jonas Helmer on 18.05.25.
//
import SwiftUI

struct CreditHeadingStyle: ViewModifier {
	func body(content: Content) -> some View {
		content
			.bold()
			.padding(.bottom, 2)
			.font(.caption)
			.foregroundStyle(.secondary)
	}
}

fileprivate struct SettingsDescriptionStyle: ViewModifier {
	func body(content: Content) -> some View {
		content
			.font(.footnote)
			.foregroundStyle(.secondary)
	}
}

fileprivate struct SettingsDescription: ViewModifier {
	let description: LocalizedStringKey
	func body(content: Content) -> some View {
		VStack(alignment: .leading) {
			content
			Text(description)
				.font(.footnote)
				.foregroundStyle(.secondary)
		}
	}
}

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
	func mediaItemDraggable(mediaItem: any MediaItem) -> some View {
		self.modifier(MediaItemDraggableModifier(mediaItem: mediaItem))
	}
	
	func settingDescriptionTextStyle() -> some View {
		self.modifier(SettingsDescriptionStyle())
	}
	
	func settingDescription(_ description: LocalizedStringKey) -> some View {
		self.modifier(SettingsDescription(description: description))
	}
}
