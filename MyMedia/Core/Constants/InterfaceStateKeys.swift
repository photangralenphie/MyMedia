//
// Copyright © 2026 MyMedia.
// Licensed under the MIT License.
//

public struct InterfaceStateKeys {
	public static let selectedTab: String = "selectedTab"
	public static let sidebarCustomizations: String = "sidebarCustomizations"

	public static func sortOrder(_ id: String) -> String {
		"sortOrder\(id)"
	}

	public static func viewPreference(_ id: String) -> String {
		"viewPreference\(id)"
	}

	public static func useSections(_ id: String) -> String {
		"useSections\(id)"
	}

	private init() {}
}
