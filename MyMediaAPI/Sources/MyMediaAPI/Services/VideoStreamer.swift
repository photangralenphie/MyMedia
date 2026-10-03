//
// Copyright © 2026 MyMedia.
// Licensed under the MIT License.
//

import Foundation
import Hummingbird
import UniformTypeIdentifiers

internal struct VideoStreamer {
	private struct RequestedRange {
		let lowerBound: Int
		let upperBound: Int

		var count: Int { upperBound - lowerBound + 1 }
	}

	// Range validation and security-scoped lifetime handling are one operation.
	// swiftlint:disable:next cyclomatic_complexity
	static func response(
		for file: ResolvedVideoFile,
		request: Request,
		includeBody: Bool,
		disposition: VideoContentDisposition = .inline
	) throws -> Response {
		let didStartSecurityScope = file.url.startAccessingSecurityScopedResource()
		do {
			let attributes = try FileManager.default.attributesOfItem(atPath: file.url.path)
			guard let fileSizeNumber = attributes[.size] as? NSNumber else { throw HTTPError(.notFound) }
			let fileSize = fileSizeNumber.intValue
			guard fileSize > 0 else { throw HTTPError(.notFound) }

			let requestedRange: RequestedRange?
			if let rangeHeader = request.headers[.range] {
				guard let parsed = parse(rangeHeader, fileSize: fileSize) else {
					if didStartSecurityScope { file.url.stopAccessingSecurityScopedResource() }
					return Response(status: .rangeNotSatisfiable, headers: [.contentRange: "bytes */\(fileSize)"])
				}
				requestedRange = parsed
			} else {
				requestedRange = nil
			}

			let range = requestedRange ?? RequestedRange(lowerBound: 0, upperBound: fileSize - 1)
			let mimeType = UTType(filenameExtension: file.url.pathExtension)?.preferredMIMEType ?? "application/octet-stream"
			var headers: HTTPFields = [
				.contentType: mimeType,
				.contentLength: String(range.count),
				.acceptRanges: "bytes",
				.contentDisposition: "\(disposition.rawValue); filename=\"\(safeFilename(file.url.lastPathComponent))\""
			]
			if requestedRange != nil {
				headers[.contentRange] = "bytes \(range.lowerBound)-\(range.upperBound)/\(fileSize)"
			}

			guard includeBody else {
				if didStartSecurityScope { file.url.stopAccessingSecurityScopedResource() }
				return Response(status: requestedRange == nil ? .ok : .partialContent, headers: headers)
			}

			let url = file.url
			let body = ResponseBody(contentLength: range.count) { writer in
				defer {
					if didStartSecurityScope { url.stopAccessingSecurityScopedResource() }
				}
				let handle = try FileHandle(forReadingFrom: url)
				defer { try? handle.close() }
				try handle.seek(toOffset: UInt64(range.lowerBound))
				var remaining = range.count
				while remaining > 0 {
					let data = try handle.read(upToCount: min(128 * 1_024, remaining)) ?? Data()
					guard !data.isEmpty else { break }
					remaining -= data.count
					try await writer.write(ByteBuffer(bytes: data))
				}
				try await writer.finish(nil)
			}
			return Response(status: requestedRange == nil ? .ok : .partialContent, headers: headers, body: body)
		} catch {
			if didStartSecurityScope { file.url.stopAccessingSecurityScopedResource() }
			throw error
		}
	}

	private static func parse(_ value: String, fileSize: Int) -> RequestedRange? {
		guard value.hasPrefix("bytes="), !value.contains(",") else { return nil }
		let bounds = value.dropFirst("bytes=".count).split(separator: "-", maxSplits: 1, omittingEmptySubsequences: false)
		guard bounds.count == 2 else { return nil }

		if bounds[0].isEmpty {
			guard let suffixLength = Int(bounds[1]), suffixLength > 0 else { return nil }
			let length = min(suffixLength, fileSize)
			return RequestedRange(lowerBound: fileSize - length, upperBound: fileSize - 1)
		}

		guard let lower = Int(bounds[0]), lower >= 0, lower < fileSize else { return nil }
		let upper: Int
		if bounds[1].isEmpty {
			upper = fileSize - 1
		} else {
			guard let requestedUpper = Int(bounds[1]), requestedUpper >= lower else { return nil }
			upper = min(requestedUpper, fileSize - 1)
		}
		return RequestedRange(lowerBound: lower, upperBound: upper)
	}

	private static func safeFilename(_ filename: String) -> String {
		filename.replacingOccurrences(of: "\"", with: "")
	}

	private init() {}
}
