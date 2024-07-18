//
//  PaddingBasic.swift
//  SwiftUIBasic
//
//  Created by 김시종 on 7/18/24.
//

import SwiftUI

struct PaddingBasic: View {
    var body: some View {
        VStack (alignment: .leading, spacing: 20) {
            // 1.padding 기본
            Text("Hello World!")
                .background(Color.yellow)
                .padding() // .padding(.all, 15)
                .padding(.leading, 20)
                .background(Color.blue)
                .padding(.bottom, 20)
            
            Divider()
            
            Text("Hello World!")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 20)
            
            Text("안녕하세요. 헬러우 월드에 오신 여러분 환영합니다.안녕하세요. 헬러우 월드에 오신 여러분 환영합니다.안녕하세요. 헬러우 월드에 오신 여러분 환영합니다.안녕하세요. 헬러우 월드에 오신 여러분 환영합니다.안녕하세요. 헬러우 월드에 오신 여러분 환영합니다.안녕하세요. 헬러우 월드에 오신 여러분 환영합니다.안녕하세요. 헬러우 월드에 오신 여러분 환영합니다.")
            
        }
        //VStack 범위 밖에서 padding 설정
        .padding()
        .padding(.vertical, 30)
        .background(
            Color.white
                .cornerRadius(10)
                .shadow(
                    color: Color.black.opacity(0.3),
                    radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/,
                    x: 10, y: 10)
        )
        .padding()
    }
}

#Preview {
    PaddingBasic()
}
