//
//  SearchView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 05.10.25.
//

import SwiftUI
import AwesomeSwiftyComponents

struct SearchView: View {
	
	let mediaItems: [any MediaItem]
	
	@State private var isSearchBarFocused: Bool = true
	@State private var searchText: String = ""
	
	@State private var isTitlesOpen: Bool = true
	@State private var isDescriptionOpen: Bool = true
	
	@State private var searchVm: SearchVm = SearchVm(mediaItems: [])
	
    var body: some View {
		NavigationStack {
			if searchVm.searchText.isEmpty {
				ContentUnavailableView("Searching", systemImage: "magnifyingglass", description: Text("Get started by searching for something."))
			} else {
				List {
					switch searchVm.searchScope {
						case .all:
							DisclosureGroup(isExpanded: $isTitlesOpen) {
								SearchForTitleView(preview: true)
							} label: {
								scopeTitle("Title")
							}
							
							DisclosureGroup(isExpanded: $isDescriptionOpen) {
								SearchForDescriptionView(preview: true)
							} label: {
								scopeTitle("Description")
							}
							
						case .title:
							SearchForTitleView()
							
						case .description:
							SearchForDescriptionView()
					}
				}
				.listStyle(.sidebar)
				.environment(searchVm)
			}
		}
		.sheet(isPresented: .constant(searchVm.expandedText != nil)) {
			if let text = searchVm.expandedText {
				Text(text)
					.lineLimit(nil)
					.padding()
					.toolbar { CloseButton { searchVm.expandedText = nil }}
			}
		}
		.onAppear {
			searchVm = .init(mediaItems: mediaItems)
			isSearchBarFocused = true
		}
		.searchable(text: Bindable(searchVm).searchText.animation(), isPresented: $isSearchBarFocused, prompt: "Search")
		.navigationTitle(searchVm.navigationTitle)
		.toolbar {
			ToolbarItem(placement: .secondaryAction) {
				Picker("Search Scope", selection: Bindable(searchVm).searchScope.animation()) {
					ForEach(SearchScope.allCases) { scope in
						Text(scope.rawValue)
							.tag(scope)
					}
				}
				.pickerStyle(.segmented)
			}
		}
    }
	
	private func scopeTitle(_ text: LocalizedStringKey) -> some View {
		Text(text)
			.font(.title2)
			.padding(.leading)
	}
}

#Preview {
	SearchView(mediaItems: DebugData.items)
		.frame(width: 500)
}
