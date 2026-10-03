//
// Copyright © 2026 MyMedia.
// Licensed under the MIT License.
//

import Foundation
import Hummingbird

internal struct ApiResponse {
	static func json(_ value: some Encodable, status: HTTPResponse.Status = .ok) throws -> Response {
		let encoder = JSONEncoder()
		encoder.dateEncodingStrategy = .iso8601
		let data = try encoder.encode(value)

		return dataResponse(data, contentType: "application/json; charset=utf-8", status: status)
	}

	static func html(_ html: String) -> Response {
		Response(
			status: .ok,
			headers: [.contentType: "text/html; charset=utf-8"],
			body: .init(byteBuffer: ByteBuffer(string: html))
		)
	}

	static func yaml(_ yaml: String) -> Response {
		Response(
			status: .ok,
			headers: [.contentType: "application/yaml; charset=utf-8"],
			body: .init(byteBuffer: ByteBuffer(string: yaml))
		)
	}

	static func data(_ data: Data, contentType: String, cacheControl: String? = nil) -> Response {
		var headers: HTTPFields = [.contentType: contentType]
		if let cacheControl { headers[.cacheControl] = cacheControl }
		return Response(status: .ok, headers: headers, body: .init(byteBuffer: ByteBuffer(bytes: data)))
	}

	private static func dataResponse(_ data: Data, contentType: String, status: HTTPResponse.Status) -> Response {
		Response(
			status: status,
			headers: [.contentType: contentType],
			body: .init(byteBuffer: ByteBuffer(bytes: data))
		)
	}

	private init() {}
}
