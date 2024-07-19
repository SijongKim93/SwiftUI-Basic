//
//  BindingChildBasic.swift
//  SwiftUIBasic
//
//  Created by 김시종 on 7/19/24.
//

import SwiftUI

struct BindingChildBasic: View {
    
    @State var buttonColor: Color = Color.blue
    @Binding var backgroundColor: Color
    @Binding var title: String
    
    var body: some View {
        Button(action: {
            backgroundColor = .orange
            buttonColor = Color.pink
            title = "Binding Child View"
        }, label: {
            Text("ChildView 이동")
                .foregroundColor(.white)
                .padding(10)
                .padding(.horizontal, 20)
                .background(
                    Color.blue
                )
                .cornerRadius(10)
        })
    }
}

#Preview {
    BindingChildBasic(backgroundColor: .constant(Color.orange), title: .constant("Binding Child"))
}
