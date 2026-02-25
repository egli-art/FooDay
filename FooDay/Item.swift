//
//  Item.swift
//  FooDay
//
//  Created by Yzeiri on 26/02/2026.
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
