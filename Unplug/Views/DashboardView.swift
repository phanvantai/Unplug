//
//  DashboardView.swift
//  Unplug
//
//  Created by Tai Phan Van on 19/6/25.
//

import SwiftUI
import FamilyControls

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @State private var showingAppSelection = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Authorization Status Section
                    if viewModel.authorizationStatus != .approved {
                        AuthorizationPromptView(viewModel: viewModel)
                    } else {
                        // Header Section
                        VStack {
                            Text("Today's Usage")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text(formatTime(viewModel.totalUsageToday))
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        // App Limits Section
                        if viewModel.appLimits.isEmpty {
                            EmptyStateView(showingAppSelection: $showingAppSelection)
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.appLimits, id: \.bundleIdentifier) { appLimit in
                                    AppLimitCard(appLimit: appLimit)
                                }
                            }
                        }
                    }
                    
                    // Error Message
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Unplug")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        if viewModel.authorizationStatus == .approved {
                            showingAppSelection = true
                        }
                    }) {
                        Image(systemName: "plus")
                    }
                    .disabled(viewModel.authorizationStatus != .approved)
                }
            }
            .sheet(isPresented: $showingAppSelection) {
                AppSelectionView(dashboardViewModel: viewModel) {
                    showingAppSelection = false
                }
            }
        }
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = Int(seconds) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

struct EmptyStateView: View {
    @Binding var showingAppSelection: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "apps.iphone")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            
            Text("No App Limits Set")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Add apps to monitor and set daily usage limits")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: {
                showingAppSelection = true
            }) {
                Text("Add Apps")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct AppLimitCard: View {
    let appLimit: AppLimit
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // App icon placeholder
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(String(appLimit.appName.prefix(1)))
                            .font(.headline)
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(appLimit.appName)
                        .font(.headline)
                    
                    Text("\(appLimit.formatTime(appLimit.usedTimeToday)) of \(appLimit.formatTime(appLimit.dailyLimitSeconds))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if appLimit.isLimitExceeded {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                }
            }
            
            // Progress bar
            ProgressView(value: appLimit.progressPercentage)
                .progressViewStyle(LinearProgressViewStyle(tint: appLimit.isLimitExceeded ? .red : .blue))
            
            // Remaining time
            if !appLimit.isLimitExceeded {
                Text("\(appLimit.formatTime(appLimit.remainingTimeSeconds)) remaining")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("Limit exceeded")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

struct AuthorizationPromptView: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.shield")
                .font(.system(size: 50))
                .foregroundColor(.blue)
            
            Text("Family Controls Authorization Required")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text("Unplug needs permission to monitor and restrict app usage. This helps you maintain healthy digital habits.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: {
                Task {
                    await viewModel.requestAuthorization()
                }
            }) {
                Text("Grant Permission")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            Text("Status: \(authorizationStatusText)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var authorizationStatusText: String {
        switch viewModel.authorizationStatus {
        case .notDetermined:
            return "Not Determined"
        case .denied:
            return "Denied - Please enable in Settings"
        case .approved:
            return "Approved"
        @unknown default:
            return "Unknown"
        }
    }
}

#Preview {
    DashboardView()
}
