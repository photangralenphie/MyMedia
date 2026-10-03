//
// Copyright © 2026 MyMedia.
// Licensed under the MIT License.
//

import Foundation

/// Validation failures produced while changing the media library.
public enum MediaApiMutationError: Error, Sendable {
	case mediaItemsNotFound([UUID])
	case progressExceedsDuration(durationMinutes: Int)
}
