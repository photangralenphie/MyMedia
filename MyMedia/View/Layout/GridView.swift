//
//  GridView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 31.03.25.
//

import SwiftUI
import SwiftData
import OrderedCollections

struct GridView<Header: View>: View {
	
	// init
	private let navTitle: LocalizedStringKey
	private let mediaItems: [any MediaItem]
	@ViewBuilder private var header: Header
	
	@Binding private var sortOrder: SortOption
	@State private var searchText: String = ""

	private let layout = [GridItem(.adaptive(minimum: LayoutConstants.artworkWidth), spacing: LayoutConstants.gridSpacing, alignment: .top)]
	@Environment(\.modelContext) private var moc
	
	init(mediaItems: [any MediaItem], sorting: Binding<SortOption>, navTitle: LocalizedStringKey) where Header == EmptyView {
		self.init(mediaItems: mediaItems, sorting: sorting, navTitle: navTitle, header: { EmptyView() })
	}
	
	init(mediaItems: [any MediaItem], sorting: Binding<SortOption>, navTitle: LocalizedStringKey, @ViewBuilder header: @escaping () -> Header) {
		switch sorting.wrappedValue {
			case .title:
				self.mediaItems = mediaItems.sorted(by: { $0.title < $1.title })
			case .releaseDate:
				self.mediaItems = mediaItems.sorted(by: { $0.year > $1.year})
			case .dateAdded:
				self.mediaItems = mediaItems.sorted(by: { $0.dateAdded > $1.dateAdded})
		}
		
		_sortOrder = sorting
		self.navTitle = navTitle
		self.header = header()
	}

	var filteredMediaItems: [any MediaItem] {
		if searchText.isEmpty { return mediaItems }
		
		return mediaItems.filter {
			$0.title
				.lowercased()
				.contains(searchText.lowercased())
		}
	}
	
	var groupedWatchables: OrderedDictionary<String, [any MediaItem]> {
		OrderedDictionary(grouping: filteredMediaItems) {
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
				
				header
				
				LazyVGrid(columns: layout, pinnedViews: [.sectionHeaders]) {
					ForEach(Array(groupedWatchables.keys), id: \.self) { section in
						Section {
							ForEach(groupedWatchables[section] ?? [], id: \.id) { mediaItem in
								GridCellView(mediaItem: mediaItem)
							}

						} header: {
							Text(LocalizedStringKey(section))
								.font(.title3)
								.bold()
								.padding(.horizontal)
								.padding(.vertical, 3)
								.frame(maxWidth: .infinity, alignment: .leading)
								.background(.regularMaterial)
								.padding(.horizontal, -LayoutConstants.gridSpacing)
						}
					}
				}
				.padding(.horizontal, LayoutConstants.gridSpacing)
				.toolbar {
					Picker("Sort by", systemImage: "arrow.up.arrow.down", selection: $sortOrder) {
						ForEach(SortOption.allCases) { option in
							Label(option.title, systemImage: option.systemImageName)
						}
					}
				}
			}
			.searchable(text: $searchText, placement: .automatic, prompt: "Search")
			.navigationTitle(navTitle)
		}
    }
}
