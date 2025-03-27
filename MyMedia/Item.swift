//
//  Item.swift
//  MyMedia
//
//  Created by Jonas Helmer on 27.03.25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
