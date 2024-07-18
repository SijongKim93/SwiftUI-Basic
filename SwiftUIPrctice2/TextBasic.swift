//
//  TextBasic.swift
//  SwiftUIPrctice2
//
//  Created by 김시종 on 7/17/24.
//

import SwiftUI

struct TextBasic: View {
    var body: some View {
        VStack(spacing: 20) {
            // font 사이즈를 title, body, footnote 등으로 설정하면 reponsive하게 관리가 가능하다 (크기별로)
            Text("Hello world")
                .font(.title)
//                .fontWeight(.semibold)
                .bold()
                .underline(true, color: .red)
                .italic()
                .strikethrough(true, color: .green)
            
            // 이 방법으로 하게되면 text 크기를 지정할 수 있게 된다. font 12 or 40 등.. 단점은 이 사이즈가 고정이라는것 (크기별로 사이즈를 다 잡아줘야함)
            Text("Hello World2".uppercased())
                .font(.system(size: 25, weight: .semibold, design: .serif))
            
            // multiline text alignment
            Text("Multy line Text alignment, Multy line Text alignmentMulty line Text alignmentMulty line Text alignmentMulty line Text alignmentMulty line Text alignmentMulty line Text alignmentMulty line Text alignmentMulty line Text alignmentMulty line Text alignmentMulty line Text alignmentMulty line Text alignmentMulty line Text alignment")
                .multilineTextAlignment(.leading)
                .foregroundColor(.red)
            
        }
    }
}

#Preview {
    TextBasic()
}

