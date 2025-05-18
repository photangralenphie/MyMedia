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
