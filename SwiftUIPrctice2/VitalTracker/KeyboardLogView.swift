//
//  KeyboardLogView.swift
//  VitalTracker
//
//  Created by 김시종 on 9/21/24.
//

import SwiftUI

struct KeyboardLogView: View {
    @ObservedObject var keyboardLogManager = KeyboardLogManager.shared
    
    
    var body: some View {
        NavigationView {
            List(keyboardLogManager.keyboardMetricsData) { dataPoint in
                VStack(alignment: .leading) {
                    Text("Duration: \(formatDuration(dataPoint.duration))")
                        .font(.headline)
                    HStack {
                        Text("Total Words: \(dataPoint.totalWords)")
                        Spacer()
                        Text("Total Taps: \(dataPoint.totalTaps)")
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .navigationBarTitle("Keyboard Metrics")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Fetch Data") {
                    keyboardLogManager.fetchKeyboardMetricsData()
                }
            }
        }
        .onAppear {
            keyboardLogManager.checkAndRequestAuthorization()
        }
    }
    

    func formatDuration(_ duration: TimeInterval) -> String {
            let hours = Int(duration) / 3600
            let minutes = (Int(duration) % 3600) / 60
            let seconds = Int(duration) % 60
            return String(format: "%02dh %02dm %02ds", hours, minutes, seconds)
        }
}

#Preview {
    KeyboardLogView()
}
