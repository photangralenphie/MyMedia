//
// Copyright © 2026 MyMedia.
// Licensed under the MIT License.
//

/// Appearance values clients can use to match the running MyMedia application.
public struct ApiAppearanceDTO: Codable, Sendable {
	public let colorScheme: ApiColorScheme
	public let accentColor: String

	public init(colorScheme: ApiColorScheme, accentColor: String) {
		self.colorScheme = colorScheme
		self.accentColor = accentColor
	}
}
