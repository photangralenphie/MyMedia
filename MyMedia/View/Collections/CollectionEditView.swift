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
	
	public var vm: CollectionEditVm
	
	@State private var showImageRemoveButton: Bool = false

	@Environment(\.dismiss) private var dismiss
	@Environment(\.modelContext) private var moc
	
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
							.padding(10)
							.foregroundStyle(Color.accentColor)
							.onHover { showImageRemoveButton = $0 }
					}
				}
			
			if vm.imageData != nil {
				LabeledContent("Image Size") {
					HStack {
						Text(vm.imageSizeDescription)
						Spacer()
						if vm.canDownsize {
							ImageDownsizeToggle(isOn: Bindable(vm).downSizeImage)
						}
					}
				}
				.padding(.bottom, 3)
			}
			
			LabeledContent {
				Button("Browse", systemImage: "folder", action: vm.loadImage)
					.padding(.trailing)
				
				PhotosPicker(selection: Bindable(vm).photoPickerItem, matching: .images, preferredItemEncoding: .compatible) {
					Label("Image Library", systemImage: "photo")
				}
			} label: {
				Text("Image")
			}
			.labelStyle(.titleAndIcon)
			
			TextField("Title", text: Bindable(vm).title)
			
			LabeledContent {
				TextEditor(text: Bindable(vm).description)
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
		.alert("Error loading image: \(vm.imageLoadError ?? "Unknown Error")", isPresented: Bindable(vm).imageLoadError.isNotNil()) {
			Button("OK") { vm.imageLoadError = nil	}
		}
    }
	
	func saveCollection() {
		let finalImageData = vm.getFinalImageData()
		if let collection = vm.collection {
			collection.title = vm.title
			collection.artwork = finalImageData
		} else {
			vm.collection = MediaCollection(title: vm.title, artwork: finalImageData)
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
