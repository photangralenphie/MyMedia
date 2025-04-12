//
//  Binding+EXT.swift
//  MyMedia
//
//  Created by Jonas Helmer on 12.04.25.
//

import SwiftUICore

extension Binding {
	func isNotNil<T>() -> Binding<Bool> where Value == T? {
		Binding<Bool>(
			get: { self.wrappedValue != nil },
			set: { newValue in
				if !newValue { self.wrappedValue = nil }
			}
		)
	}
}
