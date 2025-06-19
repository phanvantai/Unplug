//
//  AppSelectionView.swift
//  Unplug
//
//  Created by Tai Phan Van on 19/6/25.
//

import SwiftUI
import FamilyControls

struct AppSelectionView: View {
    @StateObject private var viewModel = AppSelectionViewModel()
    @State private var showingFamilyActivityPicker = false
    @State private var showingTimeLimitPicker = false
    @State private var selectedApp: SelectedApp?
    @State private var selectedTime: TimeInterval = 1800 // 30 minutes default
    
    let dashboardViewModel: DashboardViewModel
    let onComplete: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if !viewModel.isAuthorized {
                    AuthorizationView(viewModel: viewModel)
                } else {
                    AppSelectionContent(
                        viewModel: viewModel,
                        showingFamilyActivityPicker: $showingFamilyActivityPicker,
                        showingTimeLimitPicker: $showingTimeLimitPicker,
                        selectedApp: $selectedApp,
                        selectedTime: $selectedTime,
                        dashboardViewModel: dashboardViewModel
                    )
                }
            }
            .navigationTitle("Select Apps")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        onComplete()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        // Save all selected apps with their limits to dashboard
                        for app in viewModel.selectedApps {
                            let appLimit = AppLimit(
                                appName: app.name,
                                bundleIdentifier: app.bundleIdentifier,
                                dailyLimitSeconds: selectedTime
                            )
                            dashboardViewModel.addAppLimit(appLimit)
                        }
                        onComplete()
                    }
                    .disabled(viewModel.selectedApps.isEmpty)
                }
            }
        }
        .familyActivityPicker(isPresented: $showingFamilyActivityPicker, selection: $viewModel.familyActivitySelection)
        .onChange(of: viewModel.familyActivitySelection) { _ in
            viewModel.processFamilyActivitySelection()
        }
        .sheet(isPresented: $showingTimeLimitPicker) {
            if let app = selectedApp {
                TimeLimitPickerView(
                    appName: app.name,
                    initialTime: selectedTime,
                    onComplete: { timeLimit in
                        selectedTime = timeLimit
                        // Create and add the app limit immediately
                        let appLimit = AppLimit(
                            appName: app.name,
                            bundleIdentifier: app.bundleIdentifier,
                            dailyLimitSeconds: timeLimit
                        )
                        dashboardViewModel.addAppLimit(appLimit)
                        showingTimeLimitPicker = false
                        selectedApp = nil
                    }
                )
            }
        }
    }
}

struct AuthorizationView: View {
    @ObservedObject var viewModel: AppSelectionViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "shield.checkerboard")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Screen Time Permission Required")
                .font(.title2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text("Unplug needs access to Screen Time to monitor app usage and enforce limits.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if let error = viewModel.authorizationError {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }
            
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
        }
        .padding()
    }
}

struct AppSelectionContent: View {
    @ObservedObject var viewModel: AppSelectionViewModel
    @Binding var showingFamilyActivityPicker: Bool
    @Binding var showingTimeLimitPicker: Bool
    @Binding var selectedApp: SelectedApp?
    @Binding var selectedTime: TimeInterval
    let dashboardViewModel: DashboardViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            // Selected Apps List
            if viewModel.selectedApps.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "apps.iphone")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    
                    Text("No apps selected")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Tap the button below to select apps to monitor")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.selectedApps) { app in
                            SelectedAppRow(
                                app: app,
                                onSetLimit: {
                                    selectedApp = app
                                    showingTimeLimitPicker = true
                                },
                                onRemove: {
                                    viewModel.removeSelectedApp(app)
                                }
                            )
                        }
                    }
                    .padding()
                }
            }
            
            Spacer()
            
            // Select Apps Button
            Button(action: {
                showingFamilyActivityPicker = true
            }) {
                Text("Select Apps")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding()
        }
    }
}

struct SelectedAppRow: View {
    let app: SelectedApp
    let onSetLimit: () -> Void
    let onRemove: () -> Void
    
    var body: some View {
        HStack {
            // App icon placeholder
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.blue)
                .frame(width: 40, height: 40)
                .overlay(
                    Text(String(app.name.prefix(1)))
                        .font(.headline)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(app.name)
                    .font(.headline)
                
                Text(app.bundleIdentifier)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button("Set Limit") {
                onSetLimit()
            }
            .font(.caption)
            .foregroundColor(.blue)
            
            Button(action: onRemove) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

#Preview {
    AppSelectionView(dashboardViewModel: DashboardViewModel()) { }
}
