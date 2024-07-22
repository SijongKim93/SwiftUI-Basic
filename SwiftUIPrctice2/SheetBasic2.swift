//
//  SheetBasic2.swift
//  SwiftUIBasic
//
//  Created by 김시종 on 7/21/24.
//

import SwiftUI

struct SheetBasic2: View {
    
    // @Binding
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack(alignment: .topLeading, content: {
            Color.red.ignoresSafeArea()
            
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }, label: {
                Image(systemName: "xmark")
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .padding()
            })
        })
    }
}

#Preview {
    SheetBasic2()
}
