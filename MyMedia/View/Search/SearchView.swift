//
// Copyright © 2025 MyMedia.
// Licensed under the MIT License.
//

import AwesomeSwiftyComponents
import SwiftUI

enum SearchScope: CaseIterable, Identifiable {
	case all
	case title
	case description
	case credits

	var id: Self { self }

	var title: LocalizedStringKey {
		switch self {
			case .all: "All"
			case .title: "Title"
			case .description: "Description"
			case .credits: "Credits"
		}
	}
}

struct SearchView: View {

	let mediaItems: [any MediaItem]

	@State private var isSearchBarFocused: Bool = true
	@State private var searchText: String = ""

	@State private var isTitlesOpen: Bool = true
	@State private var isDescriptionOpen: Bool = true
	@State private var isCreditsOpen: Bool = true

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
								scopeTitle(SearchScope.title.title)
							}

							DisclosureGroup(isExpanded: $isDescriptionOpen) {
								SearchForDescriptionView(preview: true)
							} label: {
								scopeTitle(SearchScope.description.title)
							}

							DisclosureGroup(isExpanded: $isCreditsOpen) {
								SearchForCreditsView(preview: true)
							} label: {
								scopeTitle(SearchScope.credits.title)
							}

						case .title:
							SearchForTitleView()

						case .description:
							SearchForDescriptionView()

						case .credits:
							SearchForCreditsView()
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
					.toolbar { CloseButton { searchVm.expandedText = nil } }
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
						Text(scope.title)
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
