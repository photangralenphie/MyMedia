//
//  GenresView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 17.04.25.
//

import SwiftUI

struct GenresView: View {
	
	let mediaItemsByGenre: [String: [any HasGenre]]
	@State private var selectedGenre: String?
	@Binding private var sortOrder: SortOption
	
	init(mediaItems: [any HasGenre], sortOrder: Binding<SortOption>) {
		let genres = Array(Set(mediaItems.flatMap(\.genre))).sorted()
		self.mediaItemsByGenre = genres.reduce(into: [String: [TvShow]]()) { result, genre in
			result[genre] = mediaItems.filter { $0.genre.contains(genre) }
		}
		
		_selectedGenre = State(initialValue: genres.first)
		_sortOrder = sortOrder
	}
	
    var body: some View {
		HStack{
			List(mediaItemsByGenre.keys.sorted(), id: \.self, selection: $selectedGenre) { genre in
				Label(genre, systemImage: MetadataUtil.genreSymbol(for: genre))
					.badge(mediaItemsByGenre[genre]?.count ?? 0)
			}
			.frame(width: 200)
			.onChange(of: selectedGenre) { oldValue, newValue in
				if newValue == nil {
					selectedGenre = oldValue
				}
			}

			if let selectedGenre {
				ScrollView {
					GridView(mediaItems: mediaItemsByGenre[selectedGenre] ?? [], sorting: $sortOrder, navTitle: LocalizedStringKey(selectedGenre))
				}
			} else {
				ContentUnavailableView("Select a genre", systemImage: "square.on.square")
					.frame(maxWidth: .infinity)
			}
		}
    }
}
