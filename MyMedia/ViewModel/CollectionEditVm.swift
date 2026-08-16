//
// Copyright © 2025 MyMedia.
// Licensed under the MIT License.
//

import PhotosUI
import SwiftUI

struct LibraryImageData: Transferable {
	let imageData: Data?

	static var transferRepresentation: some TransferRepresentation {
		DataRepresentation(importedContentType: .image) { data in
			if NSImage(data: data) != nil {
				return LibraryImageData(imageData: data)
			}

			return LibraryImageData(imageData: nil)
		}
	}
}

@MainActor
@Observable
class CollectionEditVm: Identifiable {
	@ObservationIgnored
	var collection: MediaCollection?

	var title: String
	var description: String
	var imageData: Data? {
		didSet { self.setMaxAndDownsizedResolution() }
	}

	@ObservationIgnored
	var originalImageSize: CGSize?
	@ObservationIgnored
	var downsizedImageSize: CGSize?
	@ObservationIgnored
	var canDownsize: Bool {
		guard let originalImageSize else { return false }
		return originalImageSize.width > maxResolution.width || originalImageSize.height > maxResolution.height
	}
	@ObservationIgnored
	private var maxResolution: CGSize = { MetadataUtil.getMaxImageSize() }()
	@ObservationIgnored
	private var _downSizeImage: Bool = { UserDefaults.standard.bool(forKey: PreferenceKeys.downSizeCollectionArtwork) }()

	var downSizeImage: Bool {
		get { _downSizeImage }
		set {
			if _downSizeImage != newValue {
				UserDefaults.standard.set(newValue, forKey: PreferenceKeys.downSizeCollectionArtwork)
			}
			_downSizeImage = newValue
			self.setMaxAndDownsizedResolution()
		}
	}

	var imageLoadError: String?

	var photoPickerItem: PhotosPickerItem? {
		didSet { loadTransferableImage() }
	}

	var sheetTitle: LocalizedStringKey { collection == nil ? "New Collection" : "Edit Collection" }
	var sheetMainActionButtonTitle: LocalizedStringKey { collection == nil ? "Create" : "Save" }
	var imageSizeDescription: LocalizedStringKey = ""

	init() {
		self.title = ""
		self.description = ""
		self.imageData = nil

		self.collection = nil
	}

	init(collection: MediaCollection) {
		self.title = collection.title
		self.description = collection.collectionDescription ?? ""
		self.imageData = collection.artwork

		self.collection = collection
	}

	private func loadTransferableImage() {
		self.photoPickerItem?.loadTransferable(type: LibraryImageData.self) { result in
			Task { @MainActor in
				if case .success(let data) = result {
					self.imageData = data?.imageData
				}
			}
		}
	}

	private func setMaxAndDownsizedResolution() {
		guard let imageData, let image = NSImage(data: imageData) else {
			originalImageSize = nil
			downsizedImageSize = nil
			imageSizeDescription = ""
			return
		}

		self.originalImageSize = image.size
		let originalWidth = Int(originalImageSize!.width)
		let originalHeight = Int(originalImageSize!.height)

		if canDownsize && downSizeImage {
			downsizedImageSize = MetadataUtil.getDownSizedImageSize(originalSize: image.size, maxSize: self.maxResolution)
			let downsizedWidth = Int(downsizedImageSize!.width)
			let downsizedHeight = Int(downsizedImageSize!.height)
			imageSizeDescription = "\(originalWidth) x \(originalHeight) \(Image(systemName: "arrow.right")) \(downsizedWidth) x \(downsizedHeight)"
		} else {
			downsizedImageSize = nil
			imageSizeDescription = "\(originalWidth) x \(originalHeight)"
		}
	}

	public func getFinalImageData() -> Data? {
		guard let imageData else {
			return nil
		}

		if downSizeImage, let downsizedImageSize {
			return MetadataUtil.downSizeImage(imageData: imageData, newSize: downsizedImageSize)
		}

		return imageData
	}

	public func loadImage() {
		func selectFile(completion: @escaping @Sendable (URL) -> Void) {
			let panel = NSOpenPanel()

			panel.allowedContentTypes = [.image]
			panel.allowsMultipleSelection = false
			panel.canChooseDirectories = false
			panel.canChooseFiles = true

			panel.begin { response in
				Task { @MainActor in
					if response == .OK, let url = panel.url {
						completion(url)
					}
				}
			}
		}

		selectFile { url in
			Task { @MainActor in
				if url.startAccessingSecurityScopedResource() {
					do {
						self.imageData = try Data(contentsOf: url)
					} catch {
						self.imageLoadError = error.localizedDescription
					}

					url.stopAccessingSecurityScopedResource()
				}
			}
		}
	}
}
