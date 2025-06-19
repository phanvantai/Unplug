//
//  AppLimit.swift
//  Unplug
//
//  Created by Tai Phan Van on 19/6/25.
//

import Foundation
import SwiftData

@Model
final class AppLimit {
    var appName: String
    var bundleIdentifier: String
    var dailyLimitSeconds: TimeInterval
    var usedTimeToday: TimeInterval
    var lastResetDate: Date
    
    var isLimitExceeded: Bool {
        return usedTimeToday >= dailyLimitSeconds
    }
    
    var remainingTimeSeconds: TimeInterval {
        return max(0, dailyLimitSeconds - usedTimeToday)
    }
    
    var progressPercentage: Double {
        guard dailyLimitSeconds > 0 else { return 0 }
        return min(1.0, usedTimeToday / dailyLimitSeconds)
    }
    
    init(appName: String, bundleIdentifier: String, dailyLimitSeconds: TimeInterval) {
        self.appName = appName
        self.bundleIdentifier = bundleIdentifier
        self.dailyLimitSeconds = dailyLimitSeconds
        self.usedTimeToday = 0
        self.lastResetDate = Date()
    }
    
    func updateUsedTime(_ newUsedTime: TimeInterval) {
        // Check if we need to reset for a new day
        let calendar = Calendar.current
        if !calendar.isDate(lastResetDate, inSameDayAs: Date()) {
            resetForNewDay()
        }
        
        usedTimeToday = newUsedTime
    }
    
    func resetForNewDay() {
        usedTimeToday = 0
        lastResetDate = Date()
    }
    
    func formatTime(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = Int(seconds) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}
