//
//  AnimationBasic.swift
//  SwiftUIBasic
//
//  Created by 김시종 on 7/21/24.
//

import SwiftUI

struct AnimationBasic: View {
    
    @State var isAnimated: Bool = false
    
    let timing: Double = 1
    
    var body: some View {
        VStack {
            Button(action: {
                withAnimation(.default) {
                    isAnimated.toggle()
                }
            }, label: {
                Text("Button")
            })
            
            Spacer()
            
            RoundedRectangle(cornerRadius: isAnimated ? 50 : 0)
                .fill(isAnimated ? Color.red : Color.green)
                .frame(
                    width: isAnimated ? 100 : 300,
                    height: isAnimated ? 100 : 300
                )
                .rotationEffect(Angle(degrees: isAnimated ? 360 : 0))
                .offset(y: isAnimated ? 300 : 0)
            
            Spacer()
        }
        
        VStack {
            Button(action: {
                isAnimated.toggle()
            }, label: {
                Text("Button")
            })
            
            // 일정한 속도
            RoundedRectangle(cornerRadius: 20)
                .frame(width: isAnimated ? 350 : 50, height: 100)
                .animation(.linear(duration: timing), value: isAnimated)
            
            // 처음에 느렸다가 끝에 빨라지는 효과
            RoundedRectangle(cornerRadius: 20)
                .frame(width: isAnimated ? 350 : 50, height: 100)
                .animation(.easeIn(duration: timing), value: isAnimated)
            
            // 처음엔 빨랐다가 느려지는 효과
            RoundedRectangle(cornerRadius: 20)
                .frame(width: isAnimated ? 350 : 50, height: 100)
                .animation(.easeOut(duration: timing), value: isAnimated)
            
            // 처음과 끝에 느려지고 중간부분이 빨라짐
            RoundedRectangle(cornerRadius: 20)
                .frame(width: isAnimated ? 350 : 50, height: 100)
                .animation(.easeInOut(duration: timing), value: isAnimated)
        }
        
        // 스프링 효과 애니메이션
        VStack {
            Button(action: {
                withAnimation(.spring(
                    response: 0.5,
                    dampingFraction: 0.5,
                    blendDuration: 0
                )) {
                    isAnimated.toggle()
                }
            }, label: {
                /*@START_MENU_TOKEN@*/Text("Button")/*@END_MENU_TOKEN@*/
            })
            RoundedRectangle(cornerRadius: 20)
                .frame(width: isAnimated ? 350 : 50, height: 100)
        }
    }
} 

#Preview {
    AnimationBasic()
}
