//
//  ScreenTimeService.swift
//  Unplug
//
//  Created by Tai Phan Van on 19/6/25.
//

import Foundation
import FamilyControls
import ManagedSettings

class ScreenTimeService {
    static let shared = ScreenTimeService()
    
    private let managedSettingsStore = ManagedSettingsStore()
    private let authorizationCenter = AuthorizationCenter.shared
    
    private init() {}
    
    func checkAuthorizationStatus() -> Bool {
        return authorizationCenter.authorizationStatus == .approved
    }
    
    func requestAuthorization() async throws {
        guard authorizationCenter.authorizationStatus != .approved else { return }
        try await authorizationCenter.requestAuthorization(for: .individual)
    }
    
    func startMonitoring(for apps: Set<ApplicationToken>) throws {
        guard checkAuthorizationStatus() else {
            throw ScreenTimeError.authorizationRequired
        }
        
        // Apply restrictions immediately instead of monitoring
        // This is a simplified approach without Device Activity
        applyRestrictions(for: apps)
    }
    
    func stopMonitoring() {
        guard checkAuthorizationStatus() else { return }
        
        // Remove all restrictions
        removeRestrictions()
    }
    
    func applyRestrictions(for apps: Set<ApplicationToken>) {
        guard checkAuthorizationStatus() else { return }
        
        managedSettingsStore.shield.applications = apps
    }
    
    func removeRestrictions() {
        guard checkAuthorizationStatus() else { return }
        
        managedSettingsStore.shield.applications = nil
    }
    
    // Simplified approach without Device Activity scheduling
    func enableAppBlocking(for apps: Set<ApplicationToken>) {
        guard checkAuthorizationStatus() else { return }
        managedSettingsStore.shield.applications = apps
    }
    
    func disableAppBlocking() {
        guard checkAuthorizationStatus() else { return }
        managedSettingsStore.shield.applications = nil
    }
}

enum ScreenTimeError: Error {
    case authorizationRequired
    
    var description: String {
        switch self {
        case .authorizationRequired:
            return "Family Controls authorization is required to use screen time features"
        }
    }
}
