//
//  GenresView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 17.04.25.
//

import SwiftUI

struct GenresView: View {
	
	let watchablesByGenre: [String: [any WatchableWithGenre]]
	@State private var selectedGenre: String?
	
	init(watchables: [any WatchableWithGenre]) {
		let genres = Array(Set(watchables.flatMap(\.genre))).sorted()
		self.watchablesByGenre = genres.reduce(into: [String: [TvShow]]()) { result, genre in
			result[genre] = watchables.filter { $0.genre.contains(genre) }
		}
		
		_selectedGenre = State(initialValue: genres.first)
	}
	
    var body: some View {
		HStack{
			List(watchablesByGenre.keys.sorted(), id: \.self, selection: $selectedGenre) { genre in
				Label(genre, systemImage: MetadataUtil.genreSymbol(for: genre))
					.badge(watchablesByGenre[genre]?.count ?? 0)
			}
			.frame(width: 200)

			if let selectedGenre {
				ScrollView {
					GridView(watchable: watchablesByGenre[selectedGenre] ?? [], navTitle: "\(selectedGenre)")
				}
			} else {
				ContentUnavailableView("Select a genre", systemImage: "square.on.square")
					.frame(maxWidth: .infinity)
			}
		}
    }
}
