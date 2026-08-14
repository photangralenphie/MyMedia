//
//  LinkButtonStyle.swift
//  MyMedia
//
//  Created by Jonas Helmer on 13.04.26.
//

import SwiftUI

struct LinkButtonStyle: LabelStyle {
	func makeBody(configuration: Self.Configuration) -> some View {
		VStack {
			configuration.icon
				.controlSize(.small)
			configuration.title
				.font(.caption)
		}
		.padding(.vertical, 2)
		.frame(width: 45)
		.foregroundStyle(Color.secondary)
		.background(Color(nsColor: .controlColor))
		.clipShape(.rect(cornerRadius: 5))
	}
}

extension LabelStyle where Self == LinkButtonStyle {
	static var linkButton: LinkButtonStyle { LinkButtonStyle() }
}
