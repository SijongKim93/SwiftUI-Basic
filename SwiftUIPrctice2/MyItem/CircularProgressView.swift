//
//  CircularProgressView.swift
//  VitalTracker
//
//  Created by SiJongKim on 11/12/24.
//

import SwiftUI

struct CircularProgressView: View {
    var progress: Double
    var color: Color = .blue
    
    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(color, lineWidth: 4)
                .rotationEffect(.degrees(90))
        }
    }
}

#Preview {
    CircularProgressView(progress: 0.3)
}
