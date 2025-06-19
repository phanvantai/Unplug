//
//  NotificationService.swift
//  Unplug
//
//  Created by Tai Phan Van on 19/6/25.
//

import Foundation
import UserNotifications

class NotificationService {
    static let shared = NotificationService()
    
    private init() {}
    
    func requestPermission() async {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            print("Notification permission granted: \(granted)")
        } catch {
            print("Failed to request notification permission: \(error)")
        }
    }
    
    func scheduleTimeLimitNotification(for appName: String, timeRemaining: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = "Time Limit Warning"
        content.body = "You have \(formatTime(timeRemaining)) left for \(appName)"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "timeLimit_\(appName)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }
    
    func scheduleLimitExceededNotification(for appName: String) {
        let content = UNMutableNotificationContent()
        content.title = "Time Limit Reached"
        content.body = "You've reached your daily limit for \(appName)"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "limitExceeded_\(appName)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        if minutes < 60 {
            return "\(minutes) minutes"
        } else {
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            return "\(hours)h \(remainingMinutes)m"
        }
    }
}
