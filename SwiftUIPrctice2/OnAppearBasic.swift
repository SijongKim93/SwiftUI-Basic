//
//  OnAppearBasic.swift
//  SwiftUIBasic
//
//  Created by 김시종 on 7/22/24.
//

import SwiftUI

struct OnAppearBasic: View {
    
    @State var noticeText: String = "onAppear 시작전"
    @State var count: Int = 0
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text(noticeText)
                LazyVStack {
                    ForEach(0..<50) { _ in
                            RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                            .frame(height: 200)
                            .padding()
                            .onAppear {
                                count += 1
                            }
                    } // Loop
                } // LazyVS
            } // Scroll
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    noticeText = "onAppear 시작 완료 했습니다."
                }
            }
            .navigationTitle("생성된 박스 : \(count)")
        } // navi
    }
}

#Preview {
    OnAppearBasic()
}
