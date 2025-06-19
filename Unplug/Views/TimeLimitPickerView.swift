//
//  TimeLimitPickerView.swift
//  Unplug
//
//  Created by Tai Phan Van on 19/6/25.
//

import SwiftUI

struct TimeLimitPickerView: View {
    let appName: String
    @State private var selectedTime: TimeInterval
    let onComplete: (TimeInterval) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    private let timeOptions: [TimeInterval] = [
        900,   // 15 minutes
        1800,  // 30 minutes
        2700,  // 45 minutes
        3600,  // 1 hour
        5400,  // 1.5 hours
        7200,  // 2 hours
        10800, // 3 hours
        14400, // 4 hours
        18000  // 5 hours
    ]
    
    init(appName: String, initialTime: TimeInterval, onComplete: @escaping (TimeInterval) -> Void) {
        self.appName = appName
        self._selectedTime = State(initialValue: initialTime)
        self.onComplete = onComplete
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text("Set Daily Limit")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("for \(appName)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // Time Selection
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(timeOptions, id: \.self) { timeOption in
                            TimeOptionRow(
                                time: timeOption,
                                isSelected: selectedTime == timeOption,
                                onTap: {
                                    selectedTime = timeOption
                                }
                            )
                        }
                    }
                    .padding()
                }
                
                // Custom Time Input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Custom Time")
                        .font(.headline)
                    
                    HStack {
                        Text("Hours:")
                        Stepper(value: Binding(
                            get: { Int(selectedTime) / 3600 },
                            set: { newHours in
                                let minutes = Int(selectedTime) % 3600 / 60
                                selectedTime = TimeInterval(newHours * 3600 + minutes * 60)
                            }
                        ), in: 0...12) {
                            Text("\(Int(selectedTime) / 3600)")
                                .frame(minWidth: 30)
                        }
                        
                        Text("Minutes:")
                        Stepper(value: Binding(
                            get: { Int(selectedTime) % 3600 / 60 },
                            set: { newMinutes in
                                let hours = Int(selectedTime) / 3600
                                selectedTime = TimeInterval(hours * 3600 + newMinutes * 60)
                            }
                        ), in: 0...59, step: 15) {
                            Text("\(Int(selectedTime) % 3600 / 60)")
                                .frame(minWidth: 30)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Time Limit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onComplete(selectedTime)
                        dismiss()
                    }
                    .disabled(selectedTime == 0)
                }
            }
        }
    }
}

struct TimeOptionRow: View {
    let time: TimeInterval
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(formatTime(time))
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                } else {
                    Image(systemName: "circle")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = Int(seconds) % 3600 / 60
        
        if hours > 0 {
            if minutes > 0 {
                return "\(hours)h \(minutes)m"
            } else {
                return "\(hours)h"
            }
        } else {
            return "\(minutes)m"
        }
    }
}

#Preview {
    TimeLimitPickerView(appName: "TikTok", initialTime: 1800) { _ in }
}
