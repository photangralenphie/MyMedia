//
// Copyright © 2025 MyMedia.
// Licensed under the MIT License.
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
