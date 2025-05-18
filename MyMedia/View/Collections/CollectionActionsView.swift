//
//  CollectionActionsView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 17.05.25.
//

import SwiftUI

struct CollectionActionsView: View {
	@State public var collection: MediaCollection
	
	@Environment(\.modelContext) private var moc
	@State private var updateError: String? = nil
	
	let onDelete: () -> Void
	
    var body: some View {
		
		Button(collection.isPinned ? "Unpin" : "Pin", systemImage: collection.isPinned ? "pin.slash" : "pin", action: collection.togglePinned)
			.keyboardShortcut("p", modifiers: .command)

		Divider()
		
		Button("Delete Collection", systemImage: "trash", action: deleteCollection)
			.keyboardShortcut(.delete, modifiers: .command)
		
		Divider()
		
		Button("Edit", systemImage: "pencil") {
			
		}
	}
	
	func deleteCollection() {
		withAnimation {
			moc.delete(collection)
			onDelete()
		}
	}
}
