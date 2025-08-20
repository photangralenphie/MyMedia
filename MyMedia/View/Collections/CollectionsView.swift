//
//  CollectionsView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 11.05.25.
//

import SwiftUI
import OrderedCollections
import SwiftData

struct CollectionsView: View {
	
	@Query(sort: \MediaCollection.title) private var collections: [MediaCollection]
	@State private var searchText: String = ""
	
	@Environment(CommandResource.self) private var commandResource

	private let layout = [GridItem(.adaptive(minimum: 300), spacing: 20, alignment: .top)]

	var filteredCollections: [MediaCollection] {
		if searchText.isEmpty { return collections }
		
		return collections.filter {
			$0.title
				.lowercased()
				.contains(searchText.lowercased())
		}
	}
	
	var groupedCollections: OrderedDictionary<String, [MediaCollection]> {
		OrderedDictionary(grouping: filteredCollections) {
			String($0.title.prefix(1)).uppercased()
		}
	}
	
	var body: some View {
		
		NavigationStack {
			ScrollView {
				LazyVGrid(columns: layout, pinnedViews: [.sectionHeaders]) {
					ForEach(Array(groupedCollections.keys), id: \.self) { section in
						Section {
							ForEach(groupedCollections[section] ?? [], id: \.id) { collection in
								CollectionCellView(collection: collection)
							}

						} header: {
							LayoutSectionHeader(section: section)
								.padding(.horizontal)
						}
					}
				}
			}
			.searchable(text: $searchText, placement: .automatic, prompt: "Search")
			.navigationTitle("Collections")
			.toolbar {
				Button("Create Collection", systemImage: "plus", action: createCollection)
			}
			.sheet(item: Bindable(commandResource).collectionEditVm) { vm in
				CollectionEditView(vm: vm )
			}
		}
	}
	
	func createCollection() {
		commandResource.collectionEditVm = CollectionEditVm()
	}
}
