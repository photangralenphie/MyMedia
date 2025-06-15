//
//  CollectionEditView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 11.05.25.
//

import SwiftUI
import PhotosUI
import AwesomeSwiftyComponents

struct CollectionEditView: View {
	
	@State private var vm: CollectionEditVm
	
	@State private var showImageRemoveButton: Bool = false

	
	@Environment(\.dismiss) private var dismiss
	@Environment(\.modelContext) private var moc
	
	init() {
		self.vm = CollectionEditVm()
	}
	
	init(collection: MediaCollection) {
		self.vm = CollectionEditVm(collection: collection)
	}
	
    var body: some View {
		Form {
			Text(vm.sheetTitle)
				.font(.title)
			
			ArtworkView(imageData: vm.imageData, title: vm.title, subtitle: "", scale: 1.4)
				.onHover { showImageRemoveButton = $0 }
				.overlay(alignment: .center) {
					if vm.imageData == nil && vm.title.isEmpty {
						Image(systemName: "photo")
							.imageScale(.large)
					}
				}
				.overlay(alignment: .topTrailing) {
					if vm.imageData != nil && showImageRemoveButton {
						Button("Remove Image", systemImage: "xmark.circle.fill") { vm.imageData = nil }
							.imageScale(.large)
							.buttonStyle(.plain)
							.labelStyle(.iconOnly)
							.padding(5)
							.foregroundStyle(Color.accentColor)
							.onHover { showImageRemoveButton = $0 }
					}
				}
			
			LabeledContent {
				Button("Browse Files", systemImage: "folder", action: vm.loadImage)
					.padding(.trailing)
				
				PhotosPicker(selection: $vm.photoPickerItem, matching: .images, preferredItemEncoding: .compatible) {
					Label("Image Library", systemImage: "photo")
				}
			} label: {
				Text("Image")
			}
			.labelStyle(.titleAndIcon)
			
			TextField("Title", text: $vm.title)
			
			LabeledContent {
				TextEditor(text: $vm.description)
			} label: {
				Text("Description\n(optional)")
					.multilineTextAlignment(.trailing)
			}
						
			HStack {
				Button("Cancel", role: .cancel) { dismiss() }
				
				Spacer()
				
				Button(vm.sheetMainActionButtonTitle, action: saveCollection)
					.tint(.accentColor)
			}
		}
		.scenePadding()
		.alert("Error loading image: \(vm.imageLoadError ?? "Unknown Error")", isPresented: $vm.imageLoadError.isNotNil()) {
			Button("OK") { vm.imageLoadError = nil	}
		}
    }
	
	func saveCollection() {
		if let collection = vm.collection {
			collection.title = vm.title
			collection.artwork = vm.imageData
		} else {
			vm.collection = MediaCollection(title: vm.title, artwork: vm.imageData)
			moc.insert(vm.collection!)
		}
		
		if vm.description.isEmpty {
			vm.collection?.collectionDescription = nil
		} else {
			vm.collection?.collectionDescription = vm.description
		}

		try? moc.save()
		
		dismiss()
	}
}



