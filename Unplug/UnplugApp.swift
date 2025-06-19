//
//  UnplugApp.swift
//  Unplug
//
//  Created by Tai Phan Van on 19/6/25.
//

import SwiftUI
import SwiftData
import FamilyControls

@main
struct UnplugApp: App {
    @StateObject private var authorizationCenter = AuthorizationCenter.shared
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            AppLimit.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            DashboardView()
                .onAppear {
                    requestFamilyControlsAuthorization()
                }
        }
        .modelContainer(sharedModelContainer)
    }
    
    private func requestFamilyControlsAuthorization() {
        Task {
            do {
                try await authorizationCenter.requestAuthorization(for: .individual)
                print("Family Controls authorization granted")
            } catch {
                print("Family Controls authorization failed: \(error)")
            }
        }
    }
}
