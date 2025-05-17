//
//  NewCollectionView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 11.05.25.
//

import SwiftUI
import PhotosUI
import AwesomeSwiftyComponents

struct NewCollectionView: View {
	
	@State private var title: String = ""
	@State private var description: String = ""
	@State private var photoPickerItem: PhotosPickerItem? = nil
	@State private var imageData: Data?
	@State private var showImageRemoveButton: Bool = false
	@State private var imageLoadError: String?
	
	@Environment(\.dismiss) private var dismiss
	@Environment(\.modelContext) private var moc
	
    var body: some View {
		Form {
			Text("New Collection")
				.font(.title)
			
			ArtworkView(imageData: imageData, title: title, subtitle: "")
				.onHover { showImageRemoveButton = $0 }
				.overlay(alignment: .center) {
					if imageData == nil && title.isEmpty {
						Image(systemName: "photo")
							.imageScale(.large)
					}
				}
				.overlay(alignment: .topTrailing) {
					if imageData != nil && showImageRemoveButton {
						Button("Remove Image", systemImage: "xmark.circle.fill") { imageData = nil }
							.imageScale(.large)
							.buttonStyle(.plain)
							.labelStyle(.iconOnly)
							.padding(5)
							.foregroundStyle(Color.accentColor)
							.onHover { showImageRemoveButton = $0 }
					}
				}
			
			LabeledContent {
				Button("Browse Files", systemImage: "folder", action: loadImage)
					.padding(.trailing)
				
				PhotosPicker(selection: $photoPickerItem, matching: .images, preferredItemEncoding: .compatible) {
					Label("Image Library", systemImage: "photo")
				}
			} label: {
				Text("Image")
			}
			.labelStyle(.titleAndIcon)
			
			TextField("Title", text: $title)
			
			LabeledContent {
				TextEditor(text: $description)
			} label: {
				Text("Description\n(optional)")
					.multilineTextAlignment(.trailing)
			}
						
			HStack {
				Button("Create", action: createCollection)
				
				Spacer()
				
				Button("Cancel", role: .cancel) { dismiss() }
			}
		}
		.scenePadding()
		.onChange(of: photoPickerItem) { loadTransferableImage(from: photoPickerItem) }
		.alert("Error loading image: \(imageLoadError ?? "Unknown Error")", isPresented: $imageLoadError.isNotNil()) {
			Button("OK") { imageLoadError = nil	}
		}
    }
	
	func createCollection() {
		let collection = MediaCollection(title: title, artwork: imageData)
		if !description.isEmpty {
			collection.collectionDescription = description
		}
		
		moc.insert(collection)
		try? moc.save()
		
		dismiss()
	}
	
	private func loadTransferableImage(from imageSelection: PhotosPickerItem?) {
		imageSelection?.loadTransferable(type: LibraryImageData.self) { result in
			if case .success(let data) = result {
				imageData = data?.imageData
			}
		}
	}
	
	private func loadImage() {
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
					imageData = try Data(contentsOf: url)
				} catch {
					imageLoadError = error.localizedDescription
				}
				
				url.stopAccessingSecurityScopedResource()
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
