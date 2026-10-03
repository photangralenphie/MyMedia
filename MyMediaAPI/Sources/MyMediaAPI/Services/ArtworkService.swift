//
// Copyright © 2026 MyMedia.
// Licensed under the MIT License.
//

import Foundation
import ImageIO
import UniformTypeIdentifiers

internal struct ArtworkService {
	static func fullArtwork(from data: Data) -> ArtworkPayload {
		guard let source = CGImageSourceCreateWithData(data as CFData, nil),
			  let typeIdentifier = CGImageSourceGetType(source) as String?,
			  let mimeType = UTType(typeIdentifier)?.preferredMIMEType
		else {
			return ArtworkPayload(data: data, mimeType: "application/octet-stream")
		}
		return ArtworkPayload(data: data, mimeType: mimeType)
	}

	static func resized(from data: Data, maximumPixels: Int) -> ArtworkPayload? {
		guard let source = CGImageSourceCreateWithData(data as CFData, nil) else { return nil }
		let options: CFDictionary = [
			kCGImageSourceCreateThumbnailFromImageAlways: true,
			kCGImageSourceCreateThumbnailWithTransform: true,
			kCGImageSourceThumbnailMaxPixelSize: maximumPixels
		] as CFDictionary
		guard let image = CGImageSourceCreateThumbnailAtIndex(source, 0, options) else { return nil }

		let output = NSMutableData()
		guard let destination = CGImageDestinationCreateWithData(output, UTType.jpeg.identifier as CFString, 1, nil) else { return nil }
		CGImageDestinationAddImage(destination, image, [kCGImageDestinationLossyCompressionQuality: 0.82] as CFDictionary)
		guard CGImageDestinationFinalize(destination) else { return nil }

		return ArtworkPayload(data: output as Data, mimeType: "image/jpeg")
	}

	private init() {}
}
