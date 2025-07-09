//
//  LayoutSwitchingView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 31.03.25.
//

import SwiftUI
import SwiftData
import OrderedCollections

struct LayoutSwitchingView<Header: View>: View {
	
	// init
	private let navTitle: LocalizedStringKey
	private let mediaItems: [any MediaItem]
	@ViewBuilder private var header: Header
	
	@Binding private var sortOrder: SortOption
	@Binding private var viewPreference: ViewOption
	
	@State private var searchText: String = ""

	@Environment(\.modelContext) private var moc
	
	init(mediaItems: [any MediaItem], sorting: Binding<SortOption>, viewPreference: Binding<ViewOption>, navTitle: LocalizedStringKey) where Header == EmptyView {
		self.init(mediaItems: mediaItems, sorting: sorting, viewPreference: viewPreference, navTitle: navTitle, header: { EmptyView() })
	}
	
	init(mediaItems: [any MediaItem], sorting: Binding<SortOption>, viewPreference: Binding<ViewOption>, navTitle: LocalizedStringKey, @ViewBuilder header: @escaping () -> Header) {
		switch sorting.wrappedValue {
			case .title:
				self.mediaItems = mediaItems.sorted(by: { $0.title < $1.title })
			case .releaseDate:
				self.mediaItems = mediaItems.sorted(by: { $0.year > $1.year})
			case .dateAdded:
				self.mediaItems = mediaItems.sorted(by: { $0.dateAdded > $1.dateAdded})
		}
		
		_sortOrder = sorting
		_viewPreference = viewPreference
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
			Group {
				switch viewPreference {
					case .grid:
						ScrollView {
							header
							GridView(groupedWatchables: groupedWatchables)
						}
					case .list:
						ScrollView {
							header
							ListView(groupedWatchables: groupedWatchables)
						}
					case .detailList:
						header
						DetailListView(filteredMediaItems: filteredMediaItems)
				}
			}
			.toolbar {
				if viewPreference != .detailList {
					ToolbarItem {
						Picker("Sort by", systemImage: "arrow.up.arrow.down", selection: $sortOrder) {
							ForEach(SortOption.allCases) { option in
								Label(option.title, systemImage: option.systemImageName)
							}
						}
					}
					
					if #available(macOS 26.0, *) {
						ToolbarSpacer(.fixed)
					}
				}
				
				ToolbarItem {
					Picker("View", selection: $viewPreference) {
						ForEach(ViewOption.allCases) { option in
							Label(option.title, systemImage: option.symbolName)
						}
					}
					.pickerStyle(.segmented)
				}
			}
			.searchable(text: $searchText, placement: .automatic, prompt: "Search")
			.navigationTitle(navTitle)
		}
    }
}
