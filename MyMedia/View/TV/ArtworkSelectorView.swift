//
//  ArtworkSelectorView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 09.11.25.
//

import SwiftUI

struct ArtworkSelectorView: View {
	
	let tvShow: TvShow
	@State private var imageData: Data?
	
	@State private var isLoading: Bool = true
	@State private var alternativeArtworks: [Data] = []
	
	private let scale: Double
	private let pickerWidth: Double
	
	@Environment(\.dismiss) private var dismiss
	@Environment(\.modelContext) private var modelContext

	
	init(tvShow: TvShow) {
		self.tvShow = tvShow
		
		let scale = 0.65
		self.pickerWidth = LayoutConstants.artworkWidth * scale + 20
		self.scale = scale
	}
	
	var body: some View {
		let loadingIndicator = ProgressView().padding(.vertical, 35)
		
		NavigationStack {
			Form {
				HStack(alignment: .top) {
					VStack {
						Picker("Artwork:", selection: $imageData) {
							ForEach(Array(alternativeArtworks.enumerated()).filter { $0.offset.isMultiple(of: 2) }, id: \.element) { _, artwork in
								ArtworkView(imageData: artwork, title: "", subtitle: "", scale: scale)
									.tag(artwork)
							}
						}
						.pickerStyle(.radioGroup)
						.frame(width: pickerWidth)
						if isLoading && alternativeArtworks.count.isMultiple(of: 2) {
							loadingIndicator
						}
					}
					
					VStack {
						Picker("", selection: $imageData) {
							ForEach(Array(alternativeArtworks.enumerated()).filter { !$0.offset.isMultiple(of: 2) }, id: \.element) { _, artwork in
								ArtworkView(imageData: artwork, title: "", subtitle: "", scale: scale)
									.tag(artwork)
							}
						}
						.pickerStyle(.radioGroup)
						.frame(width: pickerWidth)
						if isLoading && !alternativeArtworks.count.isMultiple(of: 2) {
							loadingIndicator
						}
					}
					
					Divider()
					
					Picker("None:", selection: $imageData) {
						ArtworkView(imageData: nil, title: tvShow.title, subtitle: "(\(tvShow.year))", scale: scale)
							.tag(Data())
					}
					.pickerStyle(.radioGroup)
					.frame(width: pickerWidth)
				}
			}
			.frame(maxWidth: .infinity, maxHeight: 600)
			.formStyle(.grouped)
			.task { await collectAndSetArtworks() }
			.toolbar {
				ToolbarItem(placement: .confirmationAction) {
					if #available(macOS 26, *) {
						Button("Done", systemImage: "checkmark", role: .confirm, action: setArtwork)
					} else {
						Button("Done", systemImage: "checkmark", action: setArtwork)
					}
				}
				
				if !isLoading {
					ToolbarItem {
						Button("Deep Scan", systemImage: "arrow.trianglehead.counterclockwise", action: deepScan)
					}
				}

				ToolbarItem(placement: .cancellationAction) {
					Button("Cancel", role: .cancel) { dismiss() }
				}
			}
		}
	}
	
	private func collectAndSetArtworks(deepScan: Bool = false) async {
		
		let mediaImporter = MediaImporter(modelContainer: modelContext.container)
		var alternativeArtworks = Set<Data>()
		
		var episodes = Dictionary(grouping: tvShow.episodes, by: { $0.season })
			.values
			.compactMap { $0.first}
		
		if deepScan {
			episodes = tvShow.episodes
		}
		
		for episode in episodes {
			let currentEpisode = episode
			if let alternativeArtwork = try? await mediaImporter.getArtworks(url: currentEpisode.url) {
				if !alternativeArtworks.contains(alternativeArtwork) {
					alternativeArtworks.insert(alternativeArtwork)
					withAnimation {
						self.alternativeArtworks.append(alternativeArtwork)
					}

					if alternativeArtwork == tvShow.artwork {
						self.imageData = alternativeArtwork
					}
				}
			}
		}
		
		isLoading = false
	}
	
	private func deepScan() {
		isLoading = true
		alternativeArtworks = []
		
		Task {
			await collectAndSetArtworks(deepScan: true)
		}
	}
	
	private func setArtwork() {
		tvShow.artwork = imageData
		dismiss()
	}
}
