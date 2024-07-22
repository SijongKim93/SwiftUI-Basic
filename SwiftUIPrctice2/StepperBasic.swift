//
//  StepperBasic.swift
//  SwiftUIBasic
//
//  Created by 김시종 on 7/22/24.
//

import SwiftUI

struct StepperBasic: View {
    
    @State var stepperValue: Int = 0
    @State var widthChange: CGFloat = 0
    
    var body: some View {
        VStack {
            Stepper("기본 Stepper: \(stepperValue)", value: $stepperValue)
                .padding()
            
            Divider()
            
            RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                .frame(width: 100 + widthChange, height: 100)
            
            Stepper("직사각형 너비 변화") {
                differentWidth(amount: 20)
            } onDecrement: {
                differentWidth(amount: -20)
            }
        } //: VStack
    }
    
    func differentWidth(amount: CGFloat) {
        withAnimation(.easeInOut) {
            widthChange += amount
        }
    }
}

#Preview {
    StepperBasic()
}
