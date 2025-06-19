//
//  DashboardViewModel.swift
//  Unplug
//
//  Created by Tai Phan Van on 19/6/25.
//

import Foundation
import ManagedSettings
import FamilyControls
import Combine

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var appLimits: [AppLimit] = []
    @Published var totalUsageToday: TimeInterval = 0
    @Published var isMonitoringActive: Bool = false
    @Published var authorizationStatus: AuthorizationStatus = .notDetermined
    @Published var errorMessage: String?
    
    private let screenTimeService = ScreenTimeService.shared
    private let authorizationCenter = AuthorizationCenter.shared
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        authorizationStatus = authorizationCenter.authorizationStatus
        loadAppLimits()
        setupDeviceActivityMonitoring()
        observeAuthorizationChanges()
    }
    
    private func observeAuthorizationChanges() {
        // Monitor authorization status changes
        Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                let currentStatus = self?.authorizationCenter.authorizationStatus
                if self?.authorizationStatus != currentStatus {
                    self?.authorizationStatus = currentStatus ?? .notDetermined
                }
            }
            .store(in: &cancellables)
    }
    
    func requestAuthorization() async {
        do {
            try await screenTimeService.requestAuthorization()
            authorizationStatus = authorizationCenter.authorizationStatus
            errorMessage = nil
        } catch {
            errorMessage = "Failed to get authorization: \(error.localizedDescription)"
        }
    }
    
    func addAppLimit(_ appLimit: AppLimit) {
        guard screenTimeService.checkAuthorizationStatus() else {
            errorMessage = "Family Controls authorization is required"
            return
        }
        
        if !appLimits.contains(where: { $0.bundleIdentifier == appLimit.bundleIdentifier }) {
            appLimits.append(appLimit)
            saveAppLimits()
            updateManagedSettings()
        }
    }
    
    func removeAppLimit(_ appLimit: AppLimit) {
        appLimits.removeAll { $0.bundleIdentifier == appLimit.bundleIdentifier }
        saveAppLimits()
        updateManagedSettings()
    }
    
    func updateAppUsage(for bundleIdentifier: String, usageTime: TimeInterval) {
        if let index = appLimits.firstIndex(where: { $0.bundleIdentifier == bundleIdentifier }) {
            appLimits[index].updateUsedTime(usageTime)
            
            // Check if limit is exceeded and apply restrictions
            if appLimits[index].isLimitExceeded {
                applyRestrictionsForApp(bundleIdentifier)
            }
        }
        
        calculateTotalUsage()
    }
    
    private func calculateTotalUsage() {
        totalUsageToday = appLimits.reduce(0) { $0 + $1.usedTimeToday }
    }
    
    private func setupDeviceActivityMonitoring() {
        guard screenTimeService.checkAuthorizationStatus() else {
            isMonitoringActive = false
            return
        }
        
        // Set up device activity monitoring
        isMonitoringActive = true
    }
    
    private func updateManagedSettings() {
        guard screenTimeService.checkAuthorizationStatus() else { return }
        
        // Update ManagedSettings based on current app limits
        var applications: Set<ApplicationToken> = []
        
        for appLimit in appLimits {
            // In a real implementation, you'd convert bundle identifiers to ApplicationTokens
            // This requires the apps to be selected through FamilyActivityPicker
        }
        
        // Apply the restrictions using the service
        if applications.isEmpty {
            screenTimeService.removeRestrictions()
        } else {
            screenTimeService.applyRestrictions(for: applications)
        }
    }
    
    private func applyRestrictionsForApp(_ bundleIdentifier: String) {
        // This would apply restrictions using ManagedSettings
        // For now, we'll just mark the app as restricted
        print("Applying restrictions for app: \(bundleIdentifier)")
    }
    
    private func loadAppLimits() {
        // Load from UserDefaults or Core Data
        // For now, we'll start with an empty array
        if let data = UserDefaults.standard.data(forKey: "appLimits"),
           let savedLimits = try? JSONDecoder().decode([AppLimitData].self, from: data) {
            appLimits = savedLimits.map { data in
                let limit = AppLimit(appName: data.appName, bundleIdentifier: data.bundleIdentifier, dailyLimitSeconds: data.dailyLimitSeconds)
                limit.updateUsedTime(data.usedTimeToday)
                return limit
            }
        }
    }
    
    private func saveAppLimits() {
        let limitData = appLimits.map { limit in
            AppLimitData(
                appName: limit.appName,
                bundleIdentifier: limit.bundleIdentifier,
                dailyLimitSeconds: limit.dailyLimitSeconds,
                usedTimeToday: limit.usedTimeToday
            )
        }
        
        if let data = try? JSONEncoder().encode(limitData) {
            UserDefaults.standard.set(data, forKey: "appLimits")
        }
    }
}

// Helper struct for persistence
private struct AppLimitData: Codable {
    let appName: String
    let bundleIdentifier: String
    let dailyLimitSeconds: TimeInterval
    let usedTimeToday: TimeInterval
}
