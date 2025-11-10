//
//  CommandResource.swift
//  MyMedia
//
//  Created by Jonas Helmer on 14.04.25.
//

import SwiftUI
import Observation

@MainActor
@Observable
class CommandResource {
	
	/// use CommandResource in Environment in view if available.
	public static let shared = CommandResource()
	private init() { }
	
	// Importing
	public var showFileImporter: Bool = false
	public var showDirectoryImporter: Bool = false
	
	// Collections
	public var collectionEditVm: CollectionEditVm?

	// TV Shows
	public var tvShowArtworkToEdit: TvShow?
	
	// Error Handling - curent # of error codes: 10
	private var _errorMessageLines: [LocalizedStringKey]?
	public var errorMessage: Text? {
		guard let _errorMessageLines else { return nil }
		var message = Text("")
		for msg in _errorMessageLines {
			message = message + Text(msg)
			message = message + Text("\n")
		}
		
		return message
	}
	private(set) var errorTitle: LocalizedStringKey = ""
	
	public func showError(message: LocalizedStringKey, title: LocalizedStringKey, errorCode: Int) {
		errorTitle = message
		_errorMessageLines = [title, LocalizedStringKey("Error code: #\(errorCode)")]
	}
	
	public func appendErrorMessage(_ message: LocalizedStringKey, errorCode: Int) {
		if var _errorMessageLines {
			_errorMessageLines.append(message)
			_errorMessageLines.append(LocalizedStringKey("Error code: #\(errorCode)"))
			self._errorMessageLines = _errorMessageLines
		}
	}
	
	public func clearError() {
		_errorMessageLines = nil
		errorTitle = ""
	}
}
