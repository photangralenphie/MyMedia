//
//  GridView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 31.03.25.
//

import SwiftUI
import SwiftData
import OrderedCollections

enum SortOption: String, CaseIterable, Identifiable {
	case title = "Title"
	case releaseDate = "Release Date"
	case dateAdded = "Date Added"
	
	var id: Self { return self }
}

struct GridView: View {
	
	// init
	private let navTitle: LocalizedStringKey
	private let watchables: [any Watchable]
	
	@Binding private var sortOrder: SortOption
	@State private var searchText: String = ""

	private let layout = [GridItem(.adaptive(minimum: 300), spacing: 20, alignment: .top)]
	@Environment(\.modelContext) private var moc
	
	init(watchables: [any Watchable], sorting: Binding<SortOption>, navTitle: LocalizedStringKey) {
		switch sorting.wrappedValue {
			case .title:
				self.watchables = watchables.sorted(by: { $0.title < $1.title })
			case .releaseDate:
				self.watchables = watchables.sorted(by: { $0.year > $1.year})
			case .dateAdded:
				self.watchables = watchables.sorted(by: { $0.dateAdded > $1.dateAdded})
		}
		
		_sortOrder = sorting
		self.navTitle = navTitle
	}

	var filteredWatchables: [any Watchable] {
		if searchText.isEmpty { return watchables }
		
		return watchables.filter {
			$0.title
				.lowercased()
				.contains(searchText.lowercased())
		}
	}
	
	var groupedWatchables: OrderedDictionary<String, [any Watchable]> {
		OrderedDictionary(grouping: filteredWatchables) {
			switch sortOrder {
				case .releaseDate:
					String($0.year)
				case .dateAdded:
					$0.dateAddedSection
				case .title:
					String($0.title.prefix(1)).uppercased()
			}
		}
	}
	
    var body: some View {
		NavigationStack {
			ScrollView {
				LazyVGrid(columns: layout, pinnedViews: [.sectionHeaders]) {
					ForEach(Array(groupedWatchables.keys), id: \.self) { section in
						Section {
							ForEach(groupedWatchables[section] ?? [], id: \.id) { watchable in
								GridCellView(watchable: watchable)
							}

						} header: {
							Text(section)
								.font(.title3)
								.bold()
								.padding(.horizontal)
								.padding(.vertical, 3)
								.frame(maxWidth: .infinity, alignment: .leading)
								.background(.regularMaterial)
						}
					}
				}
				.toolbar {
					Picker("Sort by", selection: $sortOrder) {
						ForEach(SortOption.allCases) { option in
							Text(option.rawValue)
						}
					}
				}
			}
			.searchable(text: $searchText, placement: .automatic, prompt: "Search")
			.navigationTitle(navTitle)
		}
    }
}
