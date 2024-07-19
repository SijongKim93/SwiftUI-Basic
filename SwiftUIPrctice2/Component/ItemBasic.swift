//
//  ItemBasic.swift
//  SwiftUIBasic
//
//  Created by 김시종 on 7/19/24.
//

import SwiftUI

struct ItemBasic: View {
    var title: String
    var count: Int
    var color: Color
    
    var body: some View {
        VStack {
            Text("\(count)")
            Text(title)
        }
        .padding()
        .background(color)
        .cornerRadius(10)
    }
}

#Preview {
    ItemBasic(title: "사과", count: 1, color: .red)
}
