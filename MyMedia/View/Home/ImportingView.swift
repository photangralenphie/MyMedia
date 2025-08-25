//
//  ImportingView.swift
//  MyMedia
//
//  Created by Jonas Helmer on 05.05.25.
//

import SwiftUI

struct ImportingView: View {
	
	@State private var importRange: ClosedRange<Int>?
	@State private var currentImportFile: String?
	@State private var showImportOverlay: Bool = false
	
	@Environment(CommandResource.self) var commandResource
	@Environment(\.modelContext) private var moc
	
    var body: some View {
		
		VStack(alignment: .leading) {
			if let importRange {
				HStack {
					ProgressView(value: CGFloat(importRange.lowerBound.magnitude), total: CGFloat(importRange.upperBound.magnitude))
						.progressViewStyle(.circular)
						.colorMultiply(.accentColor)
						.frame(height: 50)
						.overlay {
							if importRange.lowerBound.magnitude == importRange.upperBound.magnitude {
								Image(systemName: "checkmark")
							}
						}
					
					VStack(alignment: .leading) {
						Text(importRange.lowerBound.magnitude == importRange.upperBound.magnitude ? "Finished Importing" : "Importing")
						
						if let currentImportFile {
							Text(currentImportFile)
								.font(.footnote)
								.lineLimit(2)
						}
					}
				}
				
				Divider()
			}
			
			Menu("Import Media", systemImage: "plus") {
				Button("Select Files", systemImage: "document.badge.plus.fill", action: importNewFilesFromSelection)
					.font(.title)
					.labelStyle(.titleAndIcon)
					.keyboardShortcut("i", modifiers: .command)
				Button("Select Directory", systemImage: "folder.fill.badge.plus", action: importNewFilesFromFolder)
					.font(.title)
					.labelStyle(.titleAndIcon)
					.keyboardShortcut("i", modifiers: [.shift, .command])
			}
			.labelStyle(.titleAndIcon)
			.padding(.vertical, 6)
			.padding(.horizontal, 3)
		}
		.onChange(of: commandResource.showDirectoryImporter) {
			if commandResource.showDirectoryImporter {
				importNewFilesFromFolder()
			}
		}
		.onChange(of: commandResource.showFileImporter) {
			if commandResource.showFileImporter {
				
			}
		}
    }
	
	private func importNewFilesFromSelection() {
		selectFiles { files in
			defer {
				for file in files {
					file.stopAccessingSecurityScopedResource()
				}
			}
			
			for file in files {
				if !file.startAccessingSecurityScopedResource() {
					Task { @MainActor in
						commandResource.showError(message: "Failed to gain access to the file \(file.absoluteString).", title: "Error while Importing", errorCode: 8)
					}
					return;
				}
			}
			
			Task { @MainActor in
				importFileRange(urls: files)
			}
		}
	}
	
	private func importNewFilesFromFolder() {
		selectFolder { folderURLs in
			var collectedURLs: [URL] = []
			
			for folderURL in folderURLs {
				if !folderURL.startAccessingSecurityScopedResource() {
					Task { @MainActor in
						commandResource.showError(message: "Failed to gain access to the selected folder.", title: "Error while Importing", errorCode: 9)
					}
					return
				}
				defer { folderURL.stopAccessingSecurityScopedResource() }

				let keys: [URLResourceKey] = [.isRegularFileKey, .contentTypeKey]
				if let enumerator = FileManager.default.enumerator(at: folderURL, includingPropertiesForKeys: keys, options: [.skipsHiddenFiles]) {
					for case let fileURL as URL in enumerator {
						do {
							let resourceValues = try fileURL.resourceValues(forKeys: Set(keys))
							if resourceValues.isRegularFile == true, let contentType = resourceValues.contentType, contentType.conforms(to: .mpeg4Movie) {
								collectedURLs.append(fileURL)
							}
						} catch {
							Task { @MainActor in
								commandResource.showError(message: "Error reading file at \(fileURL.absoluteString)", title: "Error while Importing", errorCode: 10)
							}
							folderURL.stopAccessingSecurityScopedResource()
							return
						}
					}
				}
			}
			
			Task { @MainActor in
				importFileRange(urls: collectedURLs)
			}
		}
	}
	
	func selectFolder(completion: @escaping @Sendable ([URL]) -> Void) {
		let panel = NSOpenPanel()
		panel.title = "Select a directory to import."

		panel.allowsMultipleSelection = true
		panel.canChooseDirectories = true
		panel.canChooseFiles = false

		panel.begin { response in
			if response == .OK {
				Task { @MainActor in
					completion(panel.urls)
				}
			}
		}
	}
	
	func selectFiles(completion: @escaping @Sendable ([URL]) -> Void) {
		let panel = NSOpenPanel()
		panel.title = "Select media files to import."

		panel.allowedContentTypes = [.mpeg4Movie]
		panel.allowsMultipleSelection = true
		panel.canChooseDirectories = false
		panel.canChooseFiles = true
		
		panel.begin { response in
			if response == .OK {
				Task { @MainActor in
					completion(panel.urls)
				}
			}
		}
	}
	
	private func importFileRange(urls: [URL]) {
		withAnimation { importRange = 0...urls.count }
		
		Task {
			let assembler = MediaImporter(modelContainer: moc.container)
			for (index, url) in urls.enumerated() {
				do {
					currentImportFile = url.lastPathComponent
					try await assembler.importFromFile(path: url)
					withAnimation { importRange = (index + 1)...urls.count }
				} catch let importError as ImportError {
					if commandResource.errorMessage == nil {
						MediaImporter.showImportError(importError)
					} else {
						commandResource.appendErrorMessage(importError.errorDescription, errorCode: importError.errorCode)
					}
				}
			}
			
			withAnimation { currentImportFile = nil }
			try? await Task.sleep(nanoseconds: 10_000_000_000)
			withAnimation { importRange = nil }
		}
	}
}
