//
// Copyright © 2026 MyMedia.
// Licensed under the MIT License.
//

import AwesomeSwiftyComponents
import SwiftUI

struct AboutCreditsButtonsView: View {
	@Binding var licence: Licence?
	@Binding var showCmarkGfmLicense: Bool

	var body: some View {
		VStack(alignment: .leading) {
			Button("AwesomeSwiftyComponents") {
				licence = .mit(name: "AwesomeSwiftyComponents", author: "Jonas Helmer", year: "2025")
			}

			Button("cmark-gfm") {
				showCmarkGfmLicense.toggle()
			}

			Button("NetworkImage") {
				licence = .mit(name: "NetworkImage", author: "Guille Gonzalez", year: "2020")
			}

			Button("swift-markdown-ui") {
				licence = .mit(name: "swift-markdown-ui", author: "Guillermo Gonzalez", year: "2020")
			}

			Button("swiftui-introspect") {
				licence = .mit(name: "swiftui-introspect", author: "Timber Software", year: "2019")
			}

			ForEach(apiLicences) { licence in
				if case let .apache(name, _, _) = licence {
					Button(name) {
						self.licence = licence
					}
				}
			}
		}
	}

	private let apiLicences: [Licence] = [
		.apache(name: "Hummingbird", author: "The Hummingbird Project", year: "2024"),
		.apache(name: "async-http-client", author: "The AsyncHTTPClient Project", year: "2017–2021"),
		.apache(name: "swift-algorithms", author: "Apple Inc. and the Swift project authors", year: "2020–2021"),
		.apache(name: "swift-asn1", author: "Apple Inc. and the SwiftASN1 project authors", year: "2019–2025"),
		.apache(name: "swift-async-algorithms", author: "Apple Inc. and the Swift project authors", year: "2022–2026"),
		.apache(name: "swift-atomics", author: "Apple Inc. and the Swift project authors", year: "2018–2026"),
		.apache(name: "swift-certificates", author: "Apple Inc. and the SwiftCertificates project authors", year: "2023–2026"),
		.apache(name: "swift-collections", author: "Apple Inc. and the Swift project authors", year: "2020–2026"),
		.apache(name: "swift-configuration", author: "The SwiftConfiguration Project", year: "2025"),
		.apache(name: "swift-crypto", author: "Apple Inc. and the SwiftCrypto project authors", year: "2019–2026"),
		.apache(name: "swift-distributed-tracing", author: "Apple Inc. and the Swift Distributed Tracing project authors", year: "2020–2023"),
		.apache(name: "swift-http-structured-headers", author: "Apple Inc. and the Swift project authors", year: "2022–2026"),
		.apache(name: "swift-http-types", author: "The Swift HTTP Types Project", year: "2023"),
		.apache(name: "swift-log", author: "The SwiftLog Project", year: "2018–2019"),
		.apache(name: "swift-metrics", author: "The SwiftMetrics Project", year: "2018–2019"),
		.apache(name: "swift-nio", author: "Apple Inc. and the SwiftNIO project authors", year: "2017–2026"),
		.apache(name: "swift-nio-extras", author: "Apple Inc. and the SwiftNIO project authors", year: "2017–2026"),
		.apache(name: "swift-nio-http2", author: "Apple Inc. and the SwiftNIO project authors", year: "2017–2026"),
		.apache(name: "swift-nio-ssl", author: "Apple Inc. and the SwiftNIO project authors", year: "2017–2026"),
		.apache(name: "swift-nio-transport-services", author: "Apple Inc. and the SwiftNIO project authors", year: "2017–2025"),
		.apache(name: "swift-numerics", author: "Apple Inc. and the Swift Numerics project authors", year: "2019–2025"),
		.apache(name: "swift-service-context", author: "Apple Inc. and the Swift Service Context project authors", year: "2020–2024"),
		.apache(name: "swift-service-lifecycle", author: "The ServiceLifecycle Project", year: "2019–2023"),
		.apache(name: "swift-system", author: "Apple Inc. and the Swift System project authors", year: "2020–2026"),
		.apache(name: "swift-syntax", author: "Apple Inc. and the Swift project authors", year: "2024")
	]
}

private struct ApacheDependency: Identifiable, Sendable {
	let name: String

	var id: String { name }
}
