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
	
	@State private var errorMessage: String?
	
	@Environment(CommandResource.self) var commandResource
	@Environment(\.modelContext) private var moc
	
    var body: some View {
		
		@Bindable var commandResource = commandResource
		
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
		.alert("An Error occurred while importing.", isPresented: $errorMessage.isNotNil()) {
			Button("Ok"){ errorMessage = nil }
		} message: {
			Text(errorMessage ?? "")
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
					errorMessage = "Failed to gain access to the file \(file.absoluteString)."
					return;
				}
			}
			
			importFileRange(urls: files)
		}
	}
	
	private func importNewFilesFromFolder() {
		selectFolder { folderURL in
			guard let folderURL else { return }
			if !folderURL.startAccessingSecurityScopedResource() {
				errorMessage = "Failed to gain access to the selected folder."
				return
			}
			defer { folderURL.stopAccessingSecurityScopedResource() }
			var collectedURLs: [URL] = []

			let keys: [URLResourceKey] = [.isRegularFileKey, .contentTypeKey]
			if let enumerator = FileManager.default.enumerator(at: folderURL, includingPropertiesForKeys: keys, options: [.skipsHiddenFiles]) {
				for case let fileURL as URL in enumerator {
					do {
						let resourceValues = try fileURL.resourceValues(forKeys: Set(keys))
						if resourceValues.isRegularFile == true, let contentType = resourceValues.contentType, contentType.conforms(to: .mpeg4Movie) {
							collectedURLs.append(fileURL)
						}
					} catch {
						errorMessage = "Error reading file at \(fileURL.absoluteString)"
						return
					}
				}
			}
			
			importFileRange(urls: collectedURLs)
		}
	}
	
	func selectFolder(completion: @escaping (URL?) -> Void) {
		let panel = NSOpenPanel()
		panel.title = "Select a directory to import."

		panel.allowsMultipleSelection = false
		panel.canChooseDirectories = true
		panel.canChooseFiles = false

		panel.begin { response in
			if response == .OK {
				completion(panel.url)
			}
		}
	}
	
	func selectFiles(completion: @escaping ([URL]) -> Void) {
		let panel = NSOpenPanel()
		panel.title = "Select media files to import."

		panel.allowedContentTypes = [.mpeg4Movie]
		panel.allowsMultipleSelection = true
		panel.canChooseDirectories = false
		panel.canChooseFiles = true
		
		panel.begin { response in
			if response == .OK {
				completion(panel.urls)
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
				} catch(let importError) {
					if errorMessage == nil {
						errorMessage = importError.localizedDescription
					} else {
						errorMessage! += "\n\(importError.localizedDescription)"
					}
				}
			}
			
			withAnimation { currentImportFile = nil }
			try? await Task.sleep(nanoseconds: 10_000_000_000)
			withAnimation { importRange = nil }
		}
	}
}
