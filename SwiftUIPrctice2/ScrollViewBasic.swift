//
//  ScrollViewBasic.swift
//  SwiftUIBasic
//
//  Created by 김시종 on 7/18/24.
//

import SwiftUI

struct ScrollViewBasic: View {
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                ForEach(0..<50) { index in
                    Rectangle()
                        .fill(Color.blue)
                        .frame(height: 300)
                        .overlay(
                            Text("\(index) 번")
                                .font(.title)
                        )
                }
            }
        }
        
        ScrollView(.horizontal, showsIndicators: true) {
            HStack {
                ForEach(0..<50) { index in
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: 300)
                        .overlay(
                            Text("\(index) 번")
                                .font(.title)
                        )
                }
            }
            
            ScrollView {
                LazyVStack {
                    ForEach(0..<10) { _ in
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack {
                                ForEach(0..<20) { _ in
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color.white)
                                        .frame(width: 200, height: 150)
                                        .shadow(radius: 10)
                                        .padding()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ScrollViewBasic()
}
