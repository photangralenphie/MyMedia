//
// Copyright © 2025 MyMedia.
// Licensed under the MIT License.
//

import AwesomeSwiftyComponents
import OrderedCollections
import SwiftUI

struct CreditsView: View {

	let hasCredits: any HasCredits
	@State private var selectedPerson: Person?
	@State private var proxy: GeometryProxy? = nil

	private var credits: OrderedDictionary<CreditKey, [Person]> {
		var result: OrderedDictionary<CreditKey, [Person]> = [:]
		guard let itemCredits = hasCredits.credits else { return result }

		if !itemCredits.cast.isEmpty {
			result[.cast] = itemCredits.cast
		}
		if !itemCredits.directors.isEmpty {
			result[.director] = itemCredits.directors
		}
		if !itemCredits.coDirectors.isEmpty {
			result[.coDirector] = itemCredits.coDirectors
		}
		if !itemCredits.screenwriters.isEmpty {
			result[.screenwriters] = itemCredits.screenwriters
		}
		if !itemCredits.producers.isEmpty {
			result[.producers] = itemCredits.producers
		}
		if !itemCredits.executiveProducers.isEmpty {
			result[.executiveProducers] = itemCredits.executiveProducers
		}
		if let composer = itemCredits.composer {
			result[.composer] = [composer]
		}
		return result
	}

    var body: some View {
		if let proxy = self.proxy, !credits.isEmpty {

			let availableCols = max(Int(proxy.size.width / 150), 1)
			let numCols = min(availableCols, credits.keys.count)
			let spacing = numCols > 1
				? (proxy.size.width - CGFloat(numCols) * 150) / CGFloat(numCols - 1)
				: 0
			let hasCast = credits[.cast] != nil

			Group {
				if hasCast, numCols > 1 {
					HStack(alignment: .top, spacing: spacing) {
						creditCell(forIndex: 0)
						creditGrid(indices: 1..<credits.keys.count, columnCount: numCols - 1, spacing: spacing)
					}
				} else {
					creditGrid(indices: 0..<credits.keys.count, columnCount: numCols, spacing: spacing)
				}
			}
			.navigationDestination(item: $selectedPerson) { person in
				PersonView(person: person)
			}
		}

		/// Gets the width of the available space without compromising layout positioning
		HStack { }
		.frame(maxWidth: .infinity)
		.background {
			GeometryReader { backgroundProxy in
				Rectangle()
					.onAppear { proxy = backgroundProxy }
					.onChange(of: backgroundProxy.size.width) {
						proxy = backgroundProxy
					}
			}
		}
    }

	func creditCell(forIndex: Int) -> some View {
		let creditKey = Array(credits.keys)[forIndex]

		return VStack(alignment: .leading) {
			Text(creditKey.rawValue)
				.textCase(.uppercase)
				.modifier(CreditHeadingStyle())

			if let people = credits[creditKey] {
				ForEach(people) { person in
					Text(person.name)
						.accessibilityAddTraits(.isLink)
						.font(.body.leading(.loose))
						.onTapGesture { selectedPerson = person }
				}
			}
		}
		.frame(width: 150, alignment: .leading)
	}

	private func creditGrid(indices: Range<Int>, columnCount: Int, spacing: CGFloat) -> some View {
		let columns = Array(
			repeating: GridItem(.fixed(150), spacing: spacing, alignment: .top),
			count: columnCount
		)

		return LazyVGrid(columns: columns, alignment: .leading, spacing: 16) {
			ForEach(indices, id: \.self) { index in
				creditCell(forIndex: index)
			}
		}
	}
}
