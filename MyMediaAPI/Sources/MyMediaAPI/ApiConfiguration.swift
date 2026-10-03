//
// Copyright © 2026 MyMedia.
// Licensed under the MIT License.
//

import Foundation

public struct ApiConfiguration {
	public static let allowedPorts = 1_024...65_535

	public struct Defaults {
		public static let startAtLaunch = false
		public static let port = 8_080
		public static let previewArtworkSize = 300
		public static let itemsPerPage = 50
	}

	public struct PreferenceKeys {
		public static let enabled = "api_enabled"
		public static let startAtLaunch = "api_startAtLaunch"
		public static let port = "api_port"
		public static let previewArtworkSize = "api_previewArtworkSize"
		public static let itemsPerPage = "api_itemsPerPage"
	}

	public static var isEnabled: Bool {
		UserDefaults.standard.bool(forKey: PreferenceKeys.enabled)
	}

	public static var startAtLaunch: Bool {
		UserDefaults.standard.bool(forKey: PreferenceKeys.startAtLaunch)
	}

	public static var configuredPort: Int {
		let storedPort = UserDefaults.standard.integer(forKey: PreferenceKeys.port)
		return isValid(port: storedPort) ? storedPort : Defaults.port
	}

	public static var previewArtworkSize: Int {
		let storedSize = UserDefaults.standard.integer(forKey: PreferenceKeys.previewArtworkSize)
		return storedSize > 0 ? storedSize : Defaults.previewArtworkSize
	}

	public static var itemsPerPage: Int {
		let storedNumber = UserDefaults.standard.integer(forKey: PreferenceKeys.itemsPerPage)
		return storedNumber > 0 ? storedNumber : Defaults.itemsPerPage
	}

	public static func localURL(port: Int? = nil, path: String? = nil) -> URL {
		let requestedPort = port ?? configuredPort
		let resolvedPort = isValid(port: requestedPort) ? requestedPort : Defaults.port
		let ipAddress = localIPAddress() ?? "localhost"
		var url = URL(string: "http://\(ipAddress):\(resolvedPort)")!
		if let path {
			url.append(path: path)
		}
		return url
	}

	public static func isValid(port: Int) -> Bool {
		allowedPorts.contains(port)
	}

	public static func localIPAddress() -> String? {
		var addresses: UnsafeMutablePointer<ifaddrs>?
		guard getifaddrs(&addresses) == 0 else { return nil }
		defer { freeifaddrs(addresses) }

		for pointer in sequence(first: addresses, next: { $0?.pointee.ifa_next }) {
			guard let interface = pointer?.pointee, let address = interface.ifa_addr, address.pointee.sa_family == AF_INET else { continue }

			let name = String(cString: interface.ifa_name)
			guard name != "lo0" else { continue }
			var host = [CChar](repeating: 0, count: Int(NI_MAXHOST))

			getnameinfo(address, socklen_t(address.pointee.sa_len), &host, socklen_t(host.count), nil, 0, NI_NUMERICHOST)

			return String(bytes: host.prefix { $0 != 0 }.map(UInt8.init), encoding: .utf8)
		}

		return nil
	}

	private init() {}
}
