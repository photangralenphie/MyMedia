//
//  BadgeView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 13.04.25.
//

import SwiftUI

struct BadgeView: View {
	
	let text: String
	let style: BadgeStyle
	
    var body: some View {
		
		switch style {
			case .outlined:
				Text(text)
					.font(.system(size: 7.5, weight: .bold))
					.foregroundStyle(Color.secondary)
					.padding(.horizontal, 3)
					.padding(.vertical, 1)
					.overlay(
						RoundedRectangle(cornerRadius: 3)
							.stroke(Color.secondary, lineWidth: 1.5)
					)
			case .filled:
				Text(text)
					.foregroundStyle(Color.clear)
					.font(.system(size: 8, weight: .bold))
					.padding(.horizontal, 3)
					.padding(.vertical, 1)
					.background(
						RoundedRectangle(cornerRadius: 3)
							.fill(Color.secondary)
							.overlay(
								Text(text)
									.font(.system(size: 8, weight: .bold))
									.blendMode(.destinationOut)
							)
							.compositingGroup()
					)
		}
    }
}
