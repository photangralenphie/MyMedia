//
// Copyright © 2026 MyMedia.
// Licensed under the MIT License.
//

import SwiftData
import SwiftUI

struct PersonView: View {

	let person: Person?

	@State private var sorting: SortOption = .releaseDate
	@State private var viewPreference: ViewOption = .grid
	@State private var useSections: Bool = true

    var body: some View {
		if let person {
			LayoutSwitchingView(mediaItems: person.creditedIn, sorting: $sorting, viewPreference: $viewPreference, useSections: $useSections, navTitle: "\(person.name)") {
				HStack {
					VStack(alignment: .leading) {
						Text(person.name)
							.font(.title)
							.bold()

						Text(person.roles.joined(separator: ", "))
							.font(.callout)
							.foregroundStyle(.secondary)
							.padding(.bottom, 7)

						Text("Credited in **\(person.creditedIn.count)** titles")
					}
					Spacer()
				}
				.scenePadding()
			}
		} else {
			ContentUnavailableView("Person not found", systemImage: "person.slash")
		}
	}
}
