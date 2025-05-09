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
				Button("Select Files", systemImage: "document.badge.plus.fill", action: showFilePicker)
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
		.fileImporter(isPresented: $commandResource.showFileImporter, allowedContentTypes: [.mpeg4Movie], allowsMultipleSelection: true, onCompletion: importNewFilesFromFileImporter)
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
    }

	private func importNewFilesFromFileImporter(result: Result<[URL], Error>) {
		switch result {
			case .success(let urls):
				importFileRange(urls: urls, needsSecurityScope: true)
					
			case .failure(let error):
				print("Error picking file: \(error.localizedDescription)")
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
						errorMessage = "Error reading file at \(fileURL)"
						return
					}
				}
			}
			
			importFileRange(urls: collectedURLs, needsSecurityScope: false)
		}
	}
	
	
	private func showFilePicker() {
		commandResource.showFileImporter.toggle()
	}
	
	func selectFolder(completion: @escaping (URL?) -> Void) {
		let panel = NSOpenPanel()
		panel.canChooseDirectories = true
		panel.canChooseFiles = false
		panel.allowsMultipleSelection = false
		panel.begin { response in
			if response == .OK {
				completion(panel.url)
			} else {
				completion(nil)
			}
		}
	}
	
	private func importFileRange(urls: [URL], needsSecurityScope: Bool) {
		withAnimation { importRange = 0...urls.count }
		
		Task {
			let assembler = MediaImporter(modelContainer: moc.container)
			for (index, url) in urls.enumerated() {
				do {
					currentImportFile = url.lastPathComponent
					try await assembler.importFromFile(path: url, needsSecurityScope: needsSecurityScope)
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
