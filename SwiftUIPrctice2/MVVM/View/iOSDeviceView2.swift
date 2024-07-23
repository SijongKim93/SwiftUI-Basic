//
//  iOSDeviceView2.swift
//  SwiftUIBasic
//
//  Created by 김시종 on 7/23/24.
//

import SwiftUI

struct iOSDeviceView2: View {
    
    let selectedItem: String
    
    
    var body: some View {
        ZStack {
            Color.orange.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("당신이 선택한 기기는?")
                    .font(.title)
                
                Text(selectedItem)
                    .font(.headline)
                    .foregroundColor(.orange)
                    .padding()
                    .padding(.horizontal)
                    .background(Color.white)
                    .cornerRadius(20)
                
                NavigationLink {
                    iOSDeviceView3()
                } label: {
                    Text("다음 페이지로 이동 -> ")
                        .font(.headline)
                        .foregroundColor(.orange)
                        .padding()
                        .padding(.horizontal)
                        .background(Color.white)
                        .cornerRadius(20)
                }
            }
        }
    }
}

#Preview {
    iOSDeviceView2(selectedItem: "아이폰")
}
