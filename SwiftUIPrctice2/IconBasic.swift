//
//  IconBasic.swift
//  SwiftUIBasic
//
//  Created by 김시종 on 7/18/24.
//

import SwiftUI

struct IconBasic: View {
    var body: some View {
        VStack (spacing: 20) {
            Image(systemName: "person.fill.badge.plus")
                .resizable()
            // redermode 에서 original 로 하면 실제 color에서 Multi color로 변경된다.
            // 고유 값 컬러로 변경되어 color를 변경하더라도 변경되지 않는 color값이 됩니다.
                .renderingMode(.original)
                .scaledToFill()
                .foregroundColor(Color.red)
                .frame(width: 300, height: 300)
        }
    }
}

#Preview {
    IconBasic()
}
