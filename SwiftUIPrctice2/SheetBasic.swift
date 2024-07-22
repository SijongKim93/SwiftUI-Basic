//
//  SheetBasic.swift
//  SwiftUIBasic
//
//  Created by 김시종 on 7/21/24.
//

import SwiftUI

struct SheetBasic: View {
    
    @State var showSheet: Bool = false
    
    var body: some View {
        ZStack {
            Color.green.ignoresSafeArea()
            
            Button(action: {
                showSheet.toggle()
            }, label: {
                Text("Button")
                    .foregroundColor(.green)
                    .font(.headline)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
            })
//            .sheet(isPresented: $showSheet, content: {
//                SheetBasic2()
//            })
            .fullScreenCover(isPresented: $showSheet, content: {
                SheetBasic2()
            })
        }
    }
}

#Preview {
    SheetBasic()
}
