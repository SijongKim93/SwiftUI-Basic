//
//  ButtonBasic.swift
//  SwiftUIBasic
//
//  Created by 김시종 on 7/19/24.
//

import SwiftUI

struct ButtonBasic: View {
    
    @State var mainTitle: String = "아직 버튼 안눌림"
    var body: some View {
        VStack (spacing: 20) {
            Text(mainTitle)
                .font(.title)
            
            Divider()
            
            Button(action: {
                self.mainTitle = "기본 버튼 눌림"
            }, label: {
                Text("기본 버튼")
            })
            .accentColor(.red)
            
            Divider()
            
            Button(action: {
                self.mainTitle = "저장 버튼 눌림"
            }, label: {
                Text("저장")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                    .padding(.horizontal, 20)
                    .background(
                        Color.blue
                            .cornerRadius(10)
                            .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                    )
            })
            
            Divider()
            
            Button(action: {
                self.mainTitle = "하트 버튼 눌림"
            }, label: {
                Circle()
                    .fill(Color.white)
                    .frame(width: 75, height: 75)
                    .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                    .overlay(
                        Image(systemName: "heart.fill")
                            .font(.largeTitle)
                            .foregroundColor(Color.red)
                    )
            })
            
            Divider()
            
            Button(action: {
                self.mainTitle = "완료 버튼 눌림"
            }, label: {
                Text("완료")
                    .font(.caption)
                    .bold()
                    .foregroundColor(.gray)
                    .padding()
                    .padding(.horizontal, 10)
                    .background(
                        Capsule()
                            .stroke(Color.gray, lineWidth: 2.5)
                    )
            })
        }
    }
}

#Preview {
    ButtonBasic()
}
