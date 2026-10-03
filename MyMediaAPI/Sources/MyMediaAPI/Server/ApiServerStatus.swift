//
// Copyright © 2026 MyMedia.
// Licensed under the MIT License.
//

public enum ApiServerStatus: Equatable, Sendable {
	case stopped
	case starting
	case running
	case stopping
	case failed(String)
}
