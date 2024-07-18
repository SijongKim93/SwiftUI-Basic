//
//  ScrollView.swift
//  SwiftUIPrctice2
//
//  Created by 김시종 on 7/3/24.
//

import SwiftUI

struct CustomScrollView: View {
    var body: some View {
        ScrollView {
            VStack {
                ForEach(0..<50) { index in
                    Text("Item \(index)")
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .padding(.bottom, 4)
                }
            }
            .padding()
        }
    }
}

#Preview {
    CustomScrollView()
}
