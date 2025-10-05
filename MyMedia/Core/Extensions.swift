//
//  Extensions.swift
//  MyMedia
//
//  Created by Jonas Helmer on 18.05.25.
//
import SwiftUI
import AVKit

extension EnvironmentValues{
	@Entry var mediaContext: MediaContext = .single
}

extension AVPlayerViewControlsStyle {
	var name: LocalizedStringKey {
		switch self {
			case .inline:
				return "Inline"
			case .minimal:
				return "Minimal"
			case .floating:
				return "Floating"
			default:
				return ""
		}
	}
	
	static var userSelectableStyles: [AVPlayerViewControlsStyle] {
		return [.floating, .inline, .minimal]
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
