//
//  ImageBasic.swift
//  SwiftUIBasic
//
//  Created by 김시종 on 7/18/24.
//

import SwiftUI

struct ImageBasic: View {
    var body: some View {
        VStack(spacing: 20) {
            Image("nature")
                .resizable()
                .scaledToFill()
                .frame(width: 300, height: 300)
                .cornerRadius(150)
            
            Divider()
            
            Image("nature")
                .resizable()
                .scaledToFill()
                .frame(width: 300, height: 300)
                .clipShape(Circle())
        }
    }
}

#Preview {
    ImageBasic()
}
