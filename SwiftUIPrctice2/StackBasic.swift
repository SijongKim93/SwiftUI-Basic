//
//  StackBasic.swift
//  SwiftUIBasic
//
//  Created by 김시종 on 7/18/24.
//

import SwiftUI

struct StackBasic: View {
    var body: some View {
        ScrollView {
            VStack (alignment: .leading, spacing: 20) {
                Rectangle()
                    .fill(Color.red)
                    .frame(width: 200, height: 200)
                
                Rectangle()
                    .fill(Color.green)
                    .frame(width: 150, height: 150)
                
                Rectangle()
                    .fill(Color.orange)
                    .frame(width: 100, height: 100)
            }
            
            HStack (spacing: 20) {
                Rectangle()
                    .fill(Color.red)
                    .frame(width: 100, height: 100)
                
                Rectangle()
                    .fill(Color.green)
                    .frame(width: 100, height: 100)
                
                Rectangle()
                    .fill(Color.orange)
                    .frame(width: 100, height: 100)
            }
            
            ZStack (alignment: .topLeading) {
                Rectangle()
                    .fill(Color.red)
                    .frame(width: 200, height: 200)
                
                Rectangle()
                    .fill(Color.green)
                    .frame(width: 150, height: 150)
                
                Rectangle()
                    .fill(Color.orange)
                    .frame(width: 100, height: 100)
            }
            
            
            ZStack (alignment: .top) {
                Rectangle()
                    .fill(Color.yellow)
                    .frame(width: 350, height: 500)
                
                VStack(alignment: .leading, spacing: 30) {
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: 150, height: 150)
                    
                    Rectangle()
                        .fill(Color.green)
                        .frame(width: 100, height: 100)
                    
                    HStack (alignment: .bottom, spacing: 10) {
                        Rectangle()
                            .fill(Color.purple)
                            .frame(width: 50, height: 50)
                        Rectangle()
                            .fill(Color.pink)
                            .frame(width: 75, height: 75)
                        Rectangle()
                            .fill(Color.blue)
                            .frame(width: 25, height: 25)
                    }
                    .background(Color.white)
                }
                .background(Color.black)
            }
            
            // ZStack vs Background의 차이
            
            VStack (spacing: 50) {
                //ZStack 을 활용해서 원에 1을 표현, 레이어가 복잡할때 z스택을 사용하면 좋음
                ZStack {
                    Circle()
                        .frame(width: 100, height: 100)
                    
                    Text("1")
                        .font(.title)
                        .foregroundColor(.white)
                }
                
                //background를 사용해서 원에 1을 표현, 레이어가 단순할때 사용하면 좋음
                Text("1")
                    .font(.title)
                    .foregroundColor(.white)
                    .background(
                        Circle()
                            .frame(width: 100, height: 100)
                    )
            }
        }
    }
}

#Preview {
    StackBasic()
}
