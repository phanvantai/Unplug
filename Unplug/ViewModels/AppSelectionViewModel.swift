//
//  AppSelectionViewModel.swift
//  Unplug
//
//  Created by Tai Phan Van on 19/6/25.
//

import Foundation
import FamilyControls
import SwiftUI
import Combine
import ManagedSettings

@MainActor
class AppSelectionViewModel: ObservableObject {
    @Published var selectedApps: [SelectedApp] = []
    @Published var isAuthorized: Bool = false
    @Published var authorizationError: String?
    @Published var familyActivitySelection = FamilyActivitySelection()
    
    private let authorizationCenter = AuthorizationCenter.shared
    
    init() {
        checkAuthorizationStatus()
    }
    
    func requestAuthorization() async {
        do {
            try await authorizationCenter.requestAuthorization(for: .individual)
            await MainActor.run {
                self.isAuthorized = true
                self.authorizationError = nil
            }
        } catch {
            await MainActor.run {
                self.authorizationError = error.localizedDescription
                self.isAuthorized = false
            }
        }
    }
    
    func checkAuthorizationStatus() {
        switch authorizationCenter.authorizationStatus {
        case .approved:
            isAuthorized = true
        case .denied:
            isAuthorized = false
            authorizationError = "Screen Time access denied. Please enable it in Settings."
        case .notDetermined:
            isAuthorized = false
        @unknown default:
            isAuthorized = false
        }
    }
    
    func addSelectedApp(_ app: SelectedApp) {
        if !selectedApps.contains(where: { $0.bundleIdentifier == app.bundleIdentifier }) {
            selectedApps.append(app)
        }
    }
    
    func removeSelectedApp(_ app: SelectedApp) {
        selectedApps.removeAll { $0.bundleIdentifier == app.bundleIdentifier }
    }
    
    func processFamilyActivitySelection() {
        selectedApps.removeAll()
        
        // Process applications
        for application in familyActivitySelection.applications {
            if let bundleId = application.bundleIdentifier,
               let displayName = application.localizedDisplayName {
                let selectedApp = SelectedApp(name: displayName, bundleIdentifier: bundleId)
                addSelectedApp(selectedApp)
            }
        }
        
        // Process application categories if needed
        for category in familyActivitySelection.categories {
            // Handle category selection if needed
            print("Selected category: \(category)")
        }
    }
}
