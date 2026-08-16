//
// Copyright © 2025 MyMedia.
// Licensed under the MIT License.
//

import OrderedCollections
import SwiftData
import SwiftUI

struct CollectionsView: View {

	@Query(sort: \MediaCollection.title) private var collections: [MediaCollection]
	@State private var searchText: String = ""
	@Environment(CommandResource.self) private var commandResource

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
				LazyVGrid(columns: LayoutConstants.gridLayout, pinnedViews: [.sectionHeaders]) {
					ForEach(Array(groupedCollections.keys), id: \.self) { section in
						Section {
							ForEach(groupedCollections[section] ?? [], id: \.id) { collection in
								LayoutCellView(collection: collection, layout: .grid)
							}
						} header: {
							LayoutSectionHeader(section: section)
						}
					}
				}
				.padding(.horizontal, LayoutConstants.gridSpacing)
			}
			.searchable(text: $searchText, placement: .automatic, prompt: "Search")
			.navigationTitle("Collections")
			.toolbar {
				Button("Create Collection", systemImage: "plus", action: createCollection)
			}
			.sheet(item: Bindable(commandResource).collectionEditVm) { vm in
				CollectionEditView(vm: vm)
			}
		}
	}

	func createCollection() {
		commandResource.collectionEditVm = CollectionEditVm()
	}
}
