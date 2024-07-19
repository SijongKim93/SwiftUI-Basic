//
//  TernaryBasic.swift
//  SwiftUIBasic
//
//  Created by 김시종 on 7/19/24.
//

import SwiftUI

struct TernaryBasic: View {
    
    @State var isStartingState: Bool = false
    
    var body: some View {
        VStack {
            Button(action: {
                isStartingState.toggle()
            }, label: {
                Text("if else 버튼: \(isStartingState.description)")
            })
            
            if isStartingState {
                RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                    .fill(Color.red)
                    .frame(width: 200, height: 100)
            } else {
                RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                    .fill(Color.blue)
                    .frame(width: 200, height: 100)
            }
            
            Button(action: {
                isStartingState.toggle()
            }, label: {
                Text("삼항연산자 버튼 : \(isStartingState.description)")
            })
            
            Text(isStartingState ? "빨강" : "파랑")
            
            RoundedRectangle(cornerRadius: isStartingState ? 25 : 0)
                .fill(isStartingState ? Color.red : Color.blue)
                .frame(
                    width: isStartingState ? 100 : 50,
                    height: isStartingState ? 400 : 100
                )
            Spacer()
        }
    }
}

#Preview {
    TernaryBasic()
}
