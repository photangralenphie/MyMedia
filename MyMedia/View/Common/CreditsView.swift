//
//  CreditsView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 26.04.25.
//

import SwiftUI
import OrderedCollections

struct CreditsView: View {
	
	let credits: OrderedDictionary<CreditKey, String>
	
	init (hasCredits: any HasCredits) {
		var credits: OrderedDictionary<CreditKey, String> = [:]
		let cast = hasCredits.cast.joined(separator: "\n")
		if !cast.isEmpty {
			credits[.cast] = cast
		}
		
		let directors = hasCredits.directors.joined(separator: "\n")
		if !directors.isEmpty {
			credits[.director] = directors
		}
		
		let coDirectors = hasCredits.coDirectors.joined(separator: "\n")
		if !coDirectors.isEmpty {
			credits[.coDirector] = coDirectors
		}
		
		let screenwriters = hasCredits.screenwriters.joined(separator: "\n")
		if !screenwriters.isEmpty {
			credits[.screenwriters] = screenwriters
		}
		
		let producers = hasCredits.producers.joined(separator: "\n")
		if !producers.isEmpty {
			credits[.producers] = producers
		}
		
		let executiveProducers = hasCredits.executiveProducers.joined(separator: "\n")
		if !executiveProducers.isEmpty {
			credits[.executiveProducers] = executiveProducers
		}
		
		if let composer = hasCredits.composer {
			credits[.composer] = composer
		}
		
		self.credits = credits
	}
	@State private var proxy: GeometryProxy? = nil
	
    var body: some View {
		if let proxy = self.proxy {
			
			let availableCols = Int(proxy.size.width / 150)
			let numCols = min(availableCols, credits.keys.count)
			let spacing = (proxy.size.width - CGFloat(numCols) * 150.0) / CGFloat(numCols - 1)
			let hasCast = credits[.cast] != nil
			
			HStack(alignment: .top, spacing: spacing) {
				if hasCast {
					creditCell(forIndex: 0)
				}
				
				VStack (alignment: .leading) {
					let startIndexRow1 = hasCast ? 1 : 0
					let endIndexRow1 = startIndexRow1 + (hasCast ? numCols - 1 : numCols) - 1
					let startIndexRow2 = endIndexRow1 + 1
					let endIndexRow2 = credits.keys.count - 1
					
					HStack(alignment: .top, spacing: spacing) {
						ForEach(startIndexRow1...endIndexRow1, id: \.self) { index in
							creditCell(forIndex: index)
						}
					}
					.padding(.bottom)
					
					if(startIndexRow2 < endIndexRow2) {
						HStack(alignment: .top, spacing: spacing) {
							ForEach(startIndexRow2...endIndexRow2, id: \.self) { index in
								creditCell(forIndex: 1)
							}
						}
					}
				}
			}
		}
		
		/// Gets the width of the available space without compromising layout positioning
		HStack { }
		.frame(maxWidth: .infinity)
		.background {
			GeometryReader { backgroundProxy in
				Rectangle()
					.onAppear() { proxy = backgroundProxy }
					.onChange(of: backgroundProxy.size.width) {
						proxy = backgroundProxy
					}
			}
		}
    }
	
	@ViewBuilder func creditCell(forIndex: Int) -> some View {
		let creditKey = Array(credits.keys)[forIndex]
		VStack(alignment: .leading) {
			Text(creditKey.rawValue)
				.textCase(.uppercase)
				.modifier(CreditHeadingStyle())
			Text(credits[creditKey] ?? "")
				.font(.body.leading(.loose))
		}
		.frame(width: 150, alignment: .leading)
	}
}
