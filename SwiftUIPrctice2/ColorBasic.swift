//
//  ColorBasic.swift
//  SwiftUIPrctice2
//
//  Created by 김시종 on 7/18/24.
//

import SwiftUI

struct ColorBasic: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Basic Color")
                .font(.title)
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.purple)
                .frame(width: 300, height: 100, alignment: .center)
            
            //Primary Color
            //자동으로 다크모드 색지원
            Text("Primary Color")
                .font(.title)
            RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                .fill(Color.secondary)
                .frame(width: 300, height: 100)
            
            //UIColor
            //UIKit에서 사용되는 color 값을 사용할 수 있다.
            Text("UI Color")
                .font(.title)
            RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                .fill(Color(UIColor.secondarySystemBackground))
                .frame(width: 300, height: 100)
            
            // ** Custom Color
            Text("Custom Color")
                .font(.title)
            RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/, style: /*@START_MENU_TOKEN@*/.continuous/*@END_MENU_TOKEN@*/)
                .fill(Color("CustomColor"))
                .frame(width: 300, height: 100)
        }
    }
}

#Preview {
    ColorBasic()
        //.preferredColorScheme(.light)
}
