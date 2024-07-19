//
//  IgnoreSafeAreaBasic.swift
//  SwiftUIBasic
//
//  Created by 김시종 on 7/19/24.
//

import SwiftUI

struct IgnoreSafeAreaBasic: View {
    var body: some View {
        ZStack {
            Color.blue
                .ignoresSafeArea()
            
            VStack {
                Text("Hello World")
                    .font(.largeTitle)
                
            }
        }
        
        ScrollView {
            VStack {
                Text("박스형 리스트")
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity)
                
                ForEach(1..<11) { index in
                        RoundedRectangle(cornerRadius: 25)
                        .fill(Color.white)
                        .frame(height: 150)
                        .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                        .padding()
                        .overlay(
                            Text("\(index)번 리스트")
                        )
                }
            }
        }
        .background(
            Color.blue
                .ignoresSafeArea()
        )
        
    }
}

#Preview {
    IgnoreSafeAreaBasic()
}
