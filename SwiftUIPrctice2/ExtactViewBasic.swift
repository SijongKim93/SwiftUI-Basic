//
//  ExtactViewBasic.swift
//  SwiftUIBasic
//
//  Created by 김시종 on 7/19/24.
//

import SwiftUI

struct ExtactViewBasic: View {
    @State var backgroundColor: Color = Color.pink
    
    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()
            
            contentLayer
        }
    }
    
    //Content
    var contentLayer: some View {
        VStack {
            Text("ExtactView 연습")
                .font(.largeTitle)
            
            Button(action: {
                buttonPressed()
            }, label: {
                Text("바탕색 변경")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(10)
            })
        }
    }
    
    //Function
    func buttonPressed() {
        backgroundColor = .yellow
    }
}

#Preview {
    ExtactViewBasic()
}
