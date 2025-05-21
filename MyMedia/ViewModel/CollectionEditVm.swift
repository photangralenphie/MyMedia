//
//  CollectionEditVm.swift
//  MyMedia
//
//  Created by Jonas Helmer on 21.05.25.
//

import SwiftUI
import _PhotosUI_SwiftUI

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


@Observable class CollectionEditVm {
	var collection: MediaCollection?
	
	var title: String
	var description: String
	var imageData: Data?
	
	var imageLoadError: String?
	
	var photoPickerItem: PhotosPickerItem? {
		didSet {
			loadTransferableImage()
		}
	}
	
	var sheetTitle: LocalizedStringKey {
		collection == nil ? "New Collection" : "Edit Collection"
	}
	
	var sheetMainActionButtonTitle: LocalizedStringKey {
		collection == nil ? "Create" : "Save"
	}
	
	init() {
		self.collection = nil
	
		self.title = ""
		self.description = ""
		self.imageData = nil
	}
	
	init(collection: MediaCollection) {
		self.title = collection.title
		self.description = collection.collectionDescription ?? ""
		self.imageData = collection.artwork
		
		self.collection = collection
	}
	
	private func loadTransferableImage() {
		self.photoPickerItem?.loadTransferable(type: LibraryImageData.self) { result in
			if case .success(let data) = result {
				self.imageData = data?.imageData
			}
		}
	}
	
	func loadImage() {
		func selectFile(completion: @escaping (URL) -> Void) {
			let panel = NSOpenPanel()

			panel.allowedContentTypes = [.image]
			panel.allowsMultipleSelection = false
			panel.canChooseDirectories = false
			panel.canChooseFiles = true
			
			panel.begin { response in
				if response == .OK {
					if let url = panel.url {
						completion(url)
					}
				}
			}
		}
		
		selectFile { url in
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
