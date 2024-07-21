//
//  TransitionBasic.swift
//  SwiftUIBasic
//
//  Created by 김시종 on 7/21/24.
//

import SwiftUI

struct TransitionBasic: View {
    
    @State var showTrasition: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                Button(action: {
                    withAnimation(.easeInOut) {
                        showTrasition.toggle()
                    }
                }, label: {
                    Text("Button")
                })
                
                Spacer()
            }
            
            if showTrasition {
                RoundedRectangle(cornerRadius: 20)
                    .frame(height: UIScreen.main.bounds.height * 0.5)
                    .opacity(showTrasition ? 1.0 : 0.0)
                    //.transition(.move(edge: .bottom))
                    //.transition(.opacity)
                    //.transition(.scale)
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading),
                        removal: .move(edge: .bottom)))
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    TransitionBasic()
}
