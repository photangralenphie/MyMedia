//
//  CollectionsTab.swift
//  MyMedia
//
//  Created by Jonas Helmer on 12.10.25.
//

import SwiftUI

struct CollectionsTab: TabContent {
	
	private let tab = Tabs.collections
	
    var body: some TabContent<TabValue> {
		GenericTab(tab: tab) {
			CollectionsView()
		}
    }
}
