//
//  SelectedApp.swift
//  Unplug
//
//  Created by Tai Phan Van on 19/6/25.
//

import Foundation

struct SelectedApp: Identifiable, Hashable, Codable {
    let id = UUID()
    let name: String
    let bundleIdentifier: String
    
    init(name: String, bundleIdentifier: String) {
        self.name = name
        self.bundleIdentifier = bundleIdentifier
    }
}
