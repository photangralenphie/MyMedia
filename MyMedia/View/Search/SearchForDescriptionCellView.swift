//
// Copyright © 2026 MyMedia.
// Licensed under the MIT License.
//

import SwiftUI

struct SearchForDescriptionCellView: View {

	let mediaItem: any MediaItem
	let highlightedTokens: AttributedString

	@Environment(SearchVm.self) private var searchVm

	@State private var showMoreButton = false

	var body: some View {
		NavigationLink {
			MediaItemDestinationView(mediaItem: mediaItem)
		} label: {
			HStack(alignment: .top) {
				ArtworkView(imageData: mediaItem.artwork, title: mediaItem.title, subtitle: "(\(String(mediaItem.year)))", scale: 0.3)

				VStack(alignment: .leading, spacing: 2) {
					Text(mediaItem.title)
						.bold()
						.padding(0)

					// If the text fits in the first item, it is, when completely expanded shorter than a linelimit of 4,
					// so it fits in the 3 lines. Otherwise the text is truncated.
					// This only works because we give the ViewThatFits a dedicated height the text has to fit in.
					ViewThatFits(in: .vertical) {
						Text(highlightedTokens)
							.lineLimit(nil)
							.frame(maxWidth: .infinity, alignment: .topLeading)
							.onAppear { showMoreButton = false }

						Text(highlightedTokens)
							.lineLimit(3)
							.frame(maxWidth: .infinity, alignment: .leading)
							.onAppear { showMoreButton = true }
					}
					.frame(maxHeight: 50)

					SearchResultSubtitle(mediaItem: mediaItem)
				}
			}
		}
		.overlay(alignment: .trailingLastTextBaseline) {
			if showMoreButton {
				Button("Show Full") {
					searchVm.expandedText = highlightedTokens
				}
				.controlSize(.small)
				.buttonStyle(.bordered)
				.buttonBorderShape(.capsule)
				.tint(Color.accentColor)
				.foregroundStyle(Color.accentColor)
				.background(Material.ultraThinMaterial, in: .capsule)
			}
		}
	}
}

#Preview {
	@Previewable @State var searchVm: SearchVm = .init(mediaItems: DebugData.items)
	let text = "Silent"
	// swiftlint:disable force_cast
	// swiftlint:disable force_unwrapping
	SearchForDescriptionCellView(mediaItem: DebugData.items.first!, highlightedTokens: AttributedString(stringLiteral: (DebugData.items.first! as! Movie).longDescription!))
	// swiftlint:enable force_cast
	// swiftlint:enable force_unwrapping
		.environment(searchVm)
		.onAppear {
			searchVm.searchText = text
		}
}
