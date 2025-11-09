//
//  GenericTab.swift
//  MyMedia
//
//  Created by Jonas Helmer on 12.10.25.
//

import SwiftUI

typealias TabValue = String

struct GenericTab<Content>: TabContent where Content: View  {
	
	let tab: Tabs
	@ViewBuilder let content: Content
	
	var body: some TabContent<TabValue> {
		Tab(tab.title, systemImage: tab.systemImage, value: tab.id) {
			content
				.navigationTitle(tab.title)
				.id(tab.id)
		}
		.customizationID(tab.id)
	}
}
