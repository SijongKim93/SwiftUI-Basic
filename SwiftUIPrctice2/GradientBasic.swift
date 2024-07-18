//
//  GradientBasic.swift
//  SwiftUIBasic
//
//  Created by 김시종 on 7/18/24.
//

import SwiftUI

struct GradientBasic: View {
    var body: some View {
        VStack(spacing: 20) {
            //Linear Gradient 선형 그라디언트
            Text("Linear Gradient")
                .font(.title)
            RoundedRectangle(cornerRadius: 25)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.red, Color.blue]),
                        startPoint: .topLeading,
                        endPoint: .bottom)
                )
                .frame(width: 300, height: 200)
            
            Text("Radial Gradient")
                .font(.title)
            RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                .fill(
                    RadialGradient(gradient: Gradient(colors: [Color.yellow, Color.purple]),
                                   center: .leading,
                                   startRadius: 5,
                                   endRadius: 200)
                )
                .frame(width: 300, height: 200)
            
            Text("Angular Gradient")
                .font(.title)
            RoundedRectangle(cornerRadius: 25)
                .fill(
                    AngularGradient(
                        gradient: Gradient(colors: [Color.blue, Color.green]),
                        center: .topLeading,
                        angle: .degrees(180))
                )
                .frame(width: 300, height: 200)
        }
    }
}

#Preview {
    GradientBasic()
}
