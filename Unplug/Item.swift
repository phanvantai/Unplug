//
//  Item.swift
//  Unplug
//
//  Created by Tai Phan Van on 19/6/25.
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
