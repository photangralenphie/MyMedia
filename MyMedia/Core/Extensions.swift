//
//  Extensions.swift
//  MyMedia
//
//  Created by Jonas Helmer on 18.05.25.
//
import AVKit
import SwiftUI

extension EnvironmentValues {
	@Entry var mediaContext: MediaContext = .single
}

extension AVPlayerViewControlsStyle {
	var name: LocalizedStringKey {
		switch self {
			case .inline: "Inline"
			case .minimal: "Minimal"
			case .floating: "Floating"
			default: ""
		}
	}

	static var userSelectableStyles: [AVPlayerViewControlsStyle] {
		[.floating, .inline, .minimal]
	}
}

extension View {
	@ViewBuilder
	func scrollEdgeSoftTopIfAvailable() -> some View {
		if #available(macOS 26.0, *) {
			self.scrollEdgeEffectStyle(.soft, for: .top)
		} else {
			self
		}
	}
}
