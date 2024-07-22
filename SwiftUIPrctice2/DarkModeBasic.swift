//
//  DarkModeBasic.swift
//  SwiftUIBasic
//
//  Created by 김시종 on 7/22/24.
//

import SwiftUI

struct DarkModeBasic: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Primary 색상")
                        .foregroundColor(.primary)
                    Text("Secondary 색상")
                        .foregroundColor(.secondary)
                    Text("Black Color")
                        .foregroundColor(.black)
                    Text("White Color")
                        .foregroundColor(.white)
                    Text("Red Color")
                        .foregroundColor(.red)
                    Text("Adaptive Color")
                        .foregroundColor(Color("AdaptiveColor"))
                    
                    Text("Environment Color")
                        .foregroundColor(colorScheme == .light ? .green : .blue)
                }
            }
        }
    }
}

#Preview {
    DarkModeBasic()
}
