//
//  CommandResource.swift
//  MyMedia
//
//  Created by Jonas Helmer on 14.04.25.
//

import SwiftUI
import Observation

@Observable
class CommandResource {
	public var showFileImporter: Bool = false
	public var showDirectoryImporter: Bool = false
	
	public init() { }
}
