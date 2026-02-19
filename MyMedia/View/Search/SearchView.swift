//
//  SearchView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 05.10.25.
//

import SwiftUI

enum SearchScope: LocalizedStringKey, CaseIterable, Identifiable {
	case all = "All"
	case title = "Title"
	case description = "Description"
	case credits = "Credits"
	
	var id: Self { self }
}

struct SearchView: View {
	
	@State private var isSearchBarFocused: Bool = true
	@State private var searchText: String = ""
	
	let bindableSearchVm: Bindable<SearchVm>
	let searchVm: SearchVm
	
	init(mediaItems: [any MediaItem]) {
		self.searchVm = SearchVm(mediaItems: mediaItems)
		self.bindableSearchVm = Bindable(searchVm)
	}
	
    var body: some View {
		NavigationStack {
			
			List {
				let mediaItemsFilteredByTitle = searchVm.mediaItemsFilteredByTitle
				DisclosureGroup("Title") {
					if mediaItemsFilteredByTitle.count > 0 {
						ForEach(mediaItemsFilteredByTitle, id: \.id) { mediaItem in
							HStack {
								ArtworkView(imageData: mediaItem.artwork, title: mediaItem.title, subtitle: "(\(String(mediaItem.year)))", scale: 0.3)
								let highlightedTokens = SearchVm.highlightResult(mediaItem.title, matching: searchVm.searchText)
								Text(highlightedTokens)
							}

						}
					} else {
						Text("No matching Titles")
					}
				}
				
				let mediaItemsFilteredByDescription = searchVm.mediaItemsFilteredByDescription
				DisclosureGroup("Description") {
					if mediaItemsFilteredByDescription.count > 0 {
						ForEach(mediaItemsFilteredByDescription, id: \.id) { mediaItem in
							HStack {
								ArtworkView(imageData: mediaItem.artwork, title: mediaItem.title, subtitle: "(\(String(mediaItem.year)))", scale: 0.3)
								let highlightedTokens = SearchVm.highlightResult(MetadataUtil.getDescription(mediaItem: mediaItem) ?? "", matching: searchVm.searchText)
								Text(highlightedTokens)
							}

						}
					} else {
						Text("No matching Description")
					}
				}
				
				DisclosureGroup("Credits") {
					
				}
			}
			.searchable(text: bindableSearchVm.searchText, isPresented: $isSearchBarFocused, placement: .toolbarPrincipal, prompt: "Search")
			.navigationTitle(searchVm.navigationTitle)
			.toolbar {
				ToolbarItem(placement: .secondaryAction) {
					Picker("Search Scope", selection: bindableSearchVm.searchScope) {
						ForEach(SearchScope.allCases) { scope in
							Text(scope.rawValue)
								.tag(scope)
						}
					}
					.pickerStyle(.segmented)
				}
			}
		}
    }
}

#Preview {
	
	let mediaItems: [any MediaItem] = [
		Movie(
			artwork: nil,
			title: "The Silent Shore",
			genre: ["Thriller", "Mystery"],
			durationMinutes: 108,
			releaseDate: Date(timeIntervalSince1970: 1_709_865_600), // 2024-06-01
			shortDescription: "A detective investigates the disappearance of a small-town fisherman.",
			longDescription: "In a remote coastal village, Detective Mara Ellison uncovers long-buried secrets as she searches for a missing man whose boat washed ashore without him. The truth may be darker than the waves suggest.",
			cast: ["Rebecca Ferguson", "Cillian Murphy", "Ben Whishaw"],
			producers: ["Kathleen Kennedy"],
			executiveProducers: ["David Fincher"],
			directors: ["Denis Villeneuve"],
			coDirectors: [],
			screenwriters: ["Phoebe Waller-Bridge"],
			composer: "Ryuichi Sakamoto",
			studio: "Netflix Studios",
			hdVideoQuality: .hd1080p,
			rating: "R",
			languages: ["en", "de"]
		),

		Movie(
			artwork: nil,
			title: "Neon Hearts",
			genre: ["Romance", "Comedy"],
			durationMinutes: 96,
			releaseDate: Date(timeIntervalSince1970: 1_713_523_200), // 2024-11-20
			shortDescription: "Two rival app developers fall in love during a tech conference.",
			longDescription: "When Sophie and Max, competing startup founders, accidentally get booked in the same hotel room, sparks fly in more ways than one. Between coding sessions and chaos, love finds its algorithm.",
			cast: ["Florence Pugh", "Nicholas Hoult"],
			producers: ["Nancy Meyers"],
			executiveProducers: ["Richard Curtis"],
			directors: ["Olivia Wilde"],
			coDirectors: [],
			screenwriters: ["Mindy Kaling"],
			composer: "Alexandre Desplat",
			studio: "Universal Pictures",
			hdVideoQuality: .hd1080p,
			rating: "PG",
			languages: ["en", "de"]
		),

		Movie(
			artwork: nil,
			title: "Iron Valleys",
			genre: ["Action", "Adventure"],
			durationMinutes: 132,
			releaseDate: Date(timeIntervalSince1970: 1_702_752_000), // 2023-11-15
			shortDescription: "A retired soldier defends his home from a corporate mining syndicate.",
			longDescription: "After years of peace in the mountains, veteran Jack Rowan is forced back into battle when a powerful corporation threatens his town. Facing impossible odds, he unites locals in a fight for survival and justice.",
			cast: ["Idris Elba", "Michelle Rodriguez", "Pedro Pascal"],
			producers: ["Jerry Bruckheimer"],
			executiveProducers: ["Kathleen Kennedy"],
			directors: ["Antoine Fuqua"],
			coDirectors: [],
			screenwriters: ["Taylor Sheridan"],
			composer: "Brian Tyler",
			studio: "Warner Bros.",
			hdVideoQuality: .hd1080p,
			rating: "PG-13",
			languages: ["en", "de"]
		),

		Movie(
			artwork: nil,
			title: "Canvas of Dreams",
			genre: ["Drama"],
			durationMinutes: 118,
			releaseDate: Date(timeIntervalSince1970: 1_707_580_800), // 2023-12-02
			shortDescription: "An artist struggles to find meaning after losing her sight.",
			longDescription: "When acclaimed painter Lucia Moretti loses her vision in an accident, she must rediscover her passion through touch, sound, and emotion. Her journey challenges the definition of art and beauty itself.",
			cast: ["Penélope Cruz", "Timothée Chalamet"],
			producers: ["Luca Guadagnino"],
			executiveProducers: ["Alfonso Cuarón"],
			directors: ["Greta Gerwig"],
			coDirectors: [],
			screenwriters: ["Emma Donoghue"],
			composer: "Ludovico Einaudi",
			studio: "A24",
			hdVideoQuality: .hd1080p,
			rating: "PG-13",
			languages: ["en", "de"]
		),

		Movie(
			artwork: nil,
			title: "Quantum Thief",
			genre: ["Science Fiction", "Heist"],
			durationMinutes: 128,
			releaseDate: Date(timeIntervalSince1970: 1_714_905_600), // 2025-03-01
			shortDescription: "A team of specialists plans the ultimate robbery—inside a quantum network.",
			longDescription: "In the near future, data is currency. A rogue hacker assembles a crew to infiltrate the world’s most secure quantum vault. But as timelines diverge, loyalty and reality begin to crumble.",
			cast: ["Daniel Kaluuya", "Zendaya", "Oscar Isaac"],
			producers: ["Simon Kinberg"],
			executiveProducers: ["Christopher Nolan"],
			directors: ["Alex Garland"],
			coDirectors: ["Lana Wachowski"],
			screenwriters: ["Alex Garland"],
			composer: "Trent Reznor & Atticus Ross",
			studio: "20th Century Studios",
			hdVideoQuality: .hd1080p,
			rating: "R",
			languages: ["en", "de"]
		)
	]
	
    SearchView(mediaItems: mediaItems)
		.frame(width: 500)
}
