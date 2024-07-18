//
//  SpacerBasic.swift
//  SwiftUIBasic
//
//  Created by 김시종 on 7/18/24.
//

import SwiftUI

struct SpacerBasic: View {
    var body: some View {
        HStack (spacing: 0) {
            Spacer(minLength: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/)
                .frame(height: 10)
                .background(Color.orange)
            
            Rectangle()
                .frame(width: 50, height: 50)
                .background(Color.white)
                .padding(.leading, 20)
                .padding(.trailing, 20)
            
            Spacer()
                .frame(height: 10)
                .background(Color.orange)
            
            Rectangle()
                .fill(Color.green)
                .frame(width: 50, height: 50)
            
            Spacer()
                .frame(height: 10)
                .background(Color.orange)
        }
        .background(Color.yellow)
        
        VStack {
            HStack (spacing: 0) {
                Image(systemName: "xmark")
                
                Spacer()
                
                Image(systemName: "gear")
            }
            .font(.title)
            .padding(.horizontal)
            
            Spacer()
        }
    }
}

#Preview {
    SpacerBasic()
}
