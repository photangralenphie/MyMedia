//
//  SearchForCreditsViewOverflowHiddenRow.swift
//  MyMedia
//
//  Created by Jonas Helmer on 19.02.26.
//

import SwiftUI
import SwiftData

struct SearchForCreditsViewOverflowHiddenRow<Content: View, OverflowIndicator: View>: View {
	public let spacing: CGFloat
	public let content: Content
	public let overflowCount: (Int) -> OverflowIndicator
	
	@State private var overflowCountInternal: Int = 0
	
	init(
		spacing: CGFloat = 8,
		@ViewBuilder content: () -> Content,
		@ViewBuilder overflow: @escaping (Int) -> OverflowIndicator
	) {
		self.spacing = spacing
		self.content = content()
		self.overflowCount = overflow
	}
	
	var body: some View {
		HStack {
			OverflowHiddenRowLayout(spacing: spacing, overflowCount: $overflowCountInternal) {
				content
			}
			
			if overflowCountInternal > 0 {
				Spacer()
				
				overflowCount(overflowCountInternal)
			}
		}
	}
}

struct OverflowHiddenRowLayout: Layout {
	public var spacing: CGFloat = 8
	@Binding public var overflowCount: Int
	
	func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
		let maxWidth = proposal.width ?? .infinity
		
		var totalWidth: CGFloat = 0
		var maxHeight: CGFloat = 0
		var visibleCount = 0
		
		for subview in subviews {
			let size = subview.sizeThatFits(.unspecified)
			
			if totalWidth + size.width > maxWidth {
				break
			}
			
			totalWidth += size.width + spacing
			maxHeight = max(maxHeight, size.height)
			visibleCount += 1
		}
		
		if totalWidth > 0 {
			totalWidth -= spacing
		}
		
		DispatchQueue.main.async {
			overflowCount = subviews.count - visibleCount
		}
		
		return CGSize(width: totalWidth, height: maxHeight)
	}

	func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
		var x = bounds.minX
		
		for subview in subviews {
			let size = subview.sizeThatFits(.unspecified)
			
			if x + size.width <= bounds.maxX {
				// Place visible views
				subview.place(
					at: CGPoint(x: x, y: bounds.minY),
					proposal: ProposedViewSize(size)
				)
				
				x += size.width + spacing
			} else {
				// Hide overflowing views
				subview.place(
					at: CGPoint(x: bounds.maxX + 1000, y: bounds.minY),
					proposal: .zero
				)
			}
		}
	}
}


#Preview {
    SearchForCreditsView()
}
