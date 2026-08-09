//
//  SearchForCreditsView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 09.08.26.
//

import SwiftUI
import SwiftData

struct SearchForCreditsView: View {

	init(preview: Bool = false) {
		self.preview = preview
	}
	
	public let preview: Bool
	
    @Environment(SearchVm.self) private var searchVm
	@Query(sort: \Person.name) private var people: [Person]

    var body: some View {
        let filteredPeople = people.filter { searchVm.matchesQuery($0.name) }
        if filteredPeople.count > 0 {
            ForEach(filteredPeople) { person in
                VStack(alignment: .leading) {
					Text(SearchVm.highlightResult(person.name, matching: searchVm.searchText))
                        .bold()
                    Text(person.roles.joined(separator: ", "))
                        .font(.caption)
					
					NavigationLink {
						PersonView(person: person)
					} label: {
						SearchForCreditsViewOverflowHiddenRow(spacing: 10) {
							ForEach(person.creditedIn, id: \.id) { mediaItem in
								VStack(alignment: .leading) {
									ArtworkView(imageData: mediaItem.artwork, title: mediaItem.title, subtitle: "(\(String(mediaItem.year)))", scale: 0.3)
									Text(mediaItem.title)
								}
							}
						} overflow: { count in
							Text("+ \(count)")
						}
					}

                    Divider()
                }
            }
        } else {
			NoSearchResultsView(preview: preview)
        }
    }
}
