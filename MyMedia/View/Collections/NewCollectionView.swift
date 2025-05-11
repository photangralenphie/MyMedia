//
//  NewCollectionView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 11.05.25.
//

import SwiftUI
import PhotosUI

struct NewCollectionView: View {
	
	@State private var title: String = ""
	@State private var description: String = ""
	@State private var photoPickerItem: PhotosPickerItem? = nil
	@State private var imageData: Data?
	
	@Environment(\.dismiss) private var dismiss
	@Environment(\.modelContext) private var moc
	
    var body: some View {
		Form {
			ArtworkView(imageData: imageData, title: title, subtitle: "")
			
			PhotosPicker(selection: $photoPickerItem, matching: .images, preferredItemEncoding: .compatible) {
				Text("Select an image from your library.")
			}
			
			TextField("Title", text: $title)
			TextField("Description", text: $description)
			
			Divider()
			
			HStack {
				Button("Create", action: createCollection)
				Button("Cancel") { dismiss() }
			}
		}
		.scenePadding()
		.onChange(of: photoPickerItem) {
			loadTransferable(from: photoPickerItem)
		}
    }
	
	func createCollection() {
		let collection = MediaCollection(title: title, artwork: imageData)
		moc.insert(collection)
		try? moc.save()
		
		dismiss()
	}
	
	private func loadTransferable(from imageSelection: PhotosPickerItem?) {
		imageSelection?.loadTransferable(type: LibraryImageData.self) { result in
			if case .success(let data) = result {
				imageData = data?.imageData
			}
		}
	}
}


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
