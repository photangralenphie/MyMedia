//
// Copyright © 2026 MyMedia.
// Licensed under the MIT License.
//

import Foundation
import Hummingbird

internal struct ApiQueryParser {
	public static func pagination(from request: Request) throws -> (page: Int, perPage: Int) {
		let defaultPerPage = ApiConfiguration.itemsPerPage
		let page = try positiveInteger(request, name: "page", default: 1)
		let perPage = try positiveInteger(request, name: "perPage", default: defaultPerPage)

		guard perPage <= 200 else { throw HTTPError(.badRequest, message: "perPage cannot exceed 200.") }
		return (page, perPage)
	}

	public static func filters(from request: Request) throws -> ApiListFilters {
		ApiListFilters(
			year: try optionalRange(request, minimumName: "minYear", maximumName: "maxYear"),
			minimumLength: try optionalInteger(request, name: "minLength"),
			maximumLength: try optionalInteger(request, name: "maxLength"),
			isFavorite: try optionalBoolean(request, name: "isFavorite"),
			isWatched: try optionalBoolean(request, name: "isWatched"),
			genre: try stringList(request, name: "genre")
		)
	}

	public static func enumValue<T: RawRepresentable>(_ request: Request, name: String, default defaultValue: T) throws -> T where T.RawValue == String {
		guard let value = request.uri.queryParameters[Substring(name)] else { return defaultValue }
		guard let result = T(rawValue: String(value)) else {
			throw HTTPError(.badRequest, message: "Invalid value for \(name).")
		}

		return result
	}

	internal static func artworkMaximumSize(from request: Request) throws -> Int? {
		guard let value = request.uri.queryParameters["maxSize"] else { return nil }
		guard let maximumSize = Int(value), (1...4_096).contains(maximumSize) else {
			throw HTTPError(.badRequest, message: "maxSize must be an integer from 1 through 4096.")
		}

		return maximumSize
	}

	private static func positiveInteger(_ request: Request, name: String, default defaultValue: Int) throws -> Int {
		guard let value = request.uri.queryParameters[Substring(name)] else { return defaultValue }
		guard let number = Int(value), number > 0 else {
			throw HTTPError(.badRequest, message: "\(name) must be a positive integer.")
		}

		return number
	}

	private static func optionalInteger(_ request: Request, name: String) throws -> Int? {
		guard let value = request.uri.queryParameters[Substring(name)] else { return nil }
		guard let number = Int(value), number >= 0 else {
			throw HTTPError(.badRequest, message: "\(name) must be a non-negative integer.")
		}

		return number
	}

	private static func optionalRange(_ request: Request, minimumName: String, maximumName: String) throws -> ClosedRange<Int>? {
		let minimum = try optionalInteger(request, name: minimumName)
		let maximum = try optionalInteger(request, name: maximumName)
		if minimum == nil || maximum == nil { return nil }

		let lowerBound = minimum ?? 0
		let upperBound = maximum ?? Int.max
		guard lowerBound <= upperBound else {
			throw HTTPError(.badRequest, message: "\(minimumName) cannot be greater than \(maximumName).")
		}

		return lowerBound...upperBound
	}

	private static func stringList(_ request: Request, name: String) throws -> [String] {
		guard let rawValue = request.uri.queryParameters[Substring(name)] else { return [] }
		let values = rawValue
			.split(separator: ",", omittingEmptySubsequences: false)
			.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }

		guard !values.isEmpty, values.allSatisfy({ !$0.isEmpty }) else {
			throw HTTPError(.badRequest, message: "\(name) must be a comma-separated list of non-empty values.")
		}

		return values
	}

	private static func optionalBoolean(_ request: Request, name: String) throws -> Bool? {
		guard let value = request.uri.queryParameters[Substring(name)] else { return nil }
		switch value.lowercased() {
			case "true", "1": return true
			case "false", "0": return false
			default: throw HTTPError(.badRequest, message: "\(name) must be true or false.")
		}
	}

	private init() {}
}
