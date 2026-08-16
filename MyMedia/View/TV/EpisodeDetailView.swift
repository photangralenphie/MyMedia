//
// Copyright © 2025 MyMedia.
// Licensed under the MIT License.
//

import SwiftUI

struct EpisodeDetailView: View {

	let episode: Episode

	@AppStorage(PreferenceKeys.showLanguageFlags) private var showLanguageFlags: Bool = true
	@AppStorage(PreferenceKeys.playButtonInArtwork) private var playButtonInArtwork: Bool = true

	var body: some View {

		List {
			VStack(alignment: .leading, spacing: 20) {
				HStack(alignment: .center, spacing: 20) {
					ArtworkView(imageData: episode.artwork, title: episode.title, subtitle: "(\(String(episode.year)))")
						.overlay { if playButtonInArtwork { PlayButtonOverlayView(mediaItem: episode) } }

					VStack(alignment: .leading, spacing: 5) {
						Spacer()

						Text(episode.title)
							.font(.largeTitle)
							.bold()

						Group {
							Text("Season \(episode.season), Episode \(episode.episode)")

							Text(episode.releaseDate.formatted(date: .abbreviated, time: .omitted))

							if let studio = episode.studio {
								Text(studio)
							}

							Text(MetadataUtil.formatRuntime(minutes: episode.durationMinutes))

							HStack {
								if let rating = MetadataUtil.getRating(ratingString: episode.rating) {
									BadgeView(text: rating, style: .outlined)
								}

								if showLanguageFlags {
									Text(MetadataUtil.flagEmojis(for: episode.languages))
								} else {
									Text(episode.languages.joined(separator: ", "))
								}
							}
						}
						.foregroundStyle(.secondary)
						.bold()
					}

					Spacer()

					if !playButtonInArtwork {
						PlayButton(mediaItem: episode)
							.keyboardShortcut("p", modifiers: .command)
					}
				}
			}
			.listRowSeparator(.hidden)

			if let description = MetadataUtil.getDescription(mediaItem: episode) {
				VStack(alignment: .leading) {
					Text("Summary")
						.textCase(.uppercase)
						.bold()
						.foregroundStyle(.secondary)
						.font(.caption)
						.padding(.bottom, 1)

					Text(description)
						.font(.body.leading(.loose))
				}
				.padding(.vertical)
			}

			CreditsView(hasCredits: episode)
		}
		.toolbar {
			Menu("Actions", systemImage: "ellipsis.circle") {
				MediaItemActionsView(mediaItem: episode, applyShortcuts: true, onDelete: popNavigation)
			}
		}
		.navigationTitle("\(episode.title) - \(episode.tvShow.title)")
	}

	func popNavigation() {
		let dismiss = Environment(\.dismiss).wrappedValue
		dismiss()
	}
}
