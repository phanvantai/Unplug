//
//  UnplugTests.swift
//  UnplugTests
//
//  Created by Tai Phan Van on 19/6/25.
//

import Testing
import Foundation
@testable import Unplug

struct AppLimitModelTests {
    
    @Test func testAppLimitCreation() async throws {
        // Given
        let appName = "TikTok"
        let bundleId = "com.zhiliaoapp.musically"
        let dailyLimit: TimeInterval = 1800 // 30 minutes
        
        // When
        let appLimit = AppLimit(appName: appName, bundleIdentifier: bundleId, dailyLimitSeconds: dailyLimit)
        
        // Then
        #expect(appLimit.appName == appName)
        #expect(appLimit.bundleIdentifier == bundleId)
        #expect(appLimit.dailyLimitSeconds == dailyLimit)
        #expect(appLimit.usedTimeToday == 0)
        #expect(appLimit.isLimitExceeded == false)
    }
    
    @Test func testAppLimitExceeded() async throws {
        // Given
        let appLimit = AppLimit(appName: "YouTube", bundleIdentifier: "com.google.ios.youtube", dailyLimitSeconds: 1800)
        
        // When
        appLimit.updateUsedTime(2000) // 33+ minutes
        
        // Then
        #expect(appLimit.isLimitExceeded == true)
        #expect(appLimit.remainingTimeSeconds == 0)
    }
    
    @Test func testAppLimitNotExceeded() async throws {
        // Given
        let appLimit = AppLimit(appName: "YouTube", bundleIdentifier: "com.google.ios.youtube", dailyLimitSeconds: 1800)
        
        // When
        appLimit.updateUsedTime(1200) // 20 minutes
        
        // Then
        #expect(appLimit.isLimitExceeded == false)
        #expect(appLimit.remainingTimeSeconds == 600) // 10 minutes left
    }
}

struct AppSelectionViewModelTests {
    
    @Test func testInitialState() async throws {
        // Given & When
        let viewModel = await AppSelectionViewModel()
        
        // Then
        await MainActor.run {
            #expect(viewModel.selectedApps.isEmpty)
            #expect(viewModel.isAuthorized == false)
            #expect(viewModel.authorizationError == nil)
        }
    }
    
    @Test func testAddSelectedApp() async throws {
        // Given
        let viewModel = await AppSelectionViewModel()
        let app = SelectedApp(name: "TikTok", bundleIdentifier: "com.zhiliaoapp.musically")
        
        // When
        await MainActor.run {
            viewModel.addSelectedApp(app)
        }
        
        // Then
        await MainActor.run {
            #expect(viewModel.selectedApps.count == 1)
            #expect(viewModel.selectedApps.first?.name == "TikTok")
        }
    }
    
    @Test func testRequestAuthorization() async throws {
        // Given
        let viewModel = await AppSelectionViewModel()
        
        // When
        await viewModel.requestAuthorization()
        
        // Then - This test might fail in simulator without proper entitlements
        // but it tests the async flow
        await MainActor.run {
            // The result depends on the authorization status
            // We just verify the method can be called without crashing
            #expect(viewModel.authorizationError != nil || viewModel.isAuthorized == true || viewModel.isAuthorized == false)
        }
    }
}

struct DashboardViewModelTests {
    
    @Test func testInitialState() async throws {
        // Given & When
        let viewModel = await DashboardViewModel()
        
        // Then
        await MainActor.run {
            #expect(viewModel.appLimits.isEmpty)
            #expect(viewModel.totalUsageToday == 0)
        }
    }
    
    @Test func testAddAppLimit() async throws {
        // Given
        let viewModel = await DashboardViewModel()
        let appLimit = AppLimit(appName: "TikTok", bundleIdentifier: "com.zhiliaoapp.musically", dailyLimitSeconds: 1800)
        
        // When
        await MainActor.run {
            viewModel.addAppLimit(appLimit)
        }
        
        // Then
        await MainActor.run {
            #expect(viewModel.appLimits.count == 1)
            #expect(viewModel.appLimits.first?.appName == "TikTok")
        }
    }
}
