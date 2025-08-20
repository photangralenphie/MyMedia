//
//  CollectionActionsView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 17.05.25.
//

import SwiftUI

struct CollectionActionsView: View {

	let collection: MediaCollection
	public var applyShortcuts: Bool
	
	@Environment(\.modelContext) private var moc
	@Environment(CommandResource.self) private var commandResource
	@State private var updateError: String? = nil
	
	let onDelete: () -> Void
	
    var body: some View {
		
		Button(collection.isPinned ? "Unpin" : "Pin", systemImage: collection.isPinned ? "pin.slash" : "pin", action: collection.togglePinned)
			.keyboardShortcut(applyShortcuts ? KeyboardShortcut("p", modifiers: .command) : nil)

		Divider()
		
		Button("Delete Collection", systemImage: "trash", action: deleteCollection)
			.keyboardShortcut(applyShortcuts ? KeyboardShortcut(.delete, modifiers: .command) : nil)
		
		Divider()
		
		Button("Edit", systemImage: "pencil", action: editCollection)
			.keyboardShortcut(applyShortcuts ? KeyboardShortcut("e", modifiers: .command) : nil)
	}
	
	func deleteCollection() {
		withAnimation {
			moc.delete(collection)
			onDelete()
		}
	}
	
	func editCollection() {
		commandResource.collectionEditVm = CollectionEditVm(collection: collection)
	}
}
