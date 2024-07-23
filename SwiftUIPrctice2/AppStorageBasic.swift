//
//  AppStorageBasic.swift
//  SwiftUIBasic
//
//  Created by 김시종 on 7/23/24.
//

import SwiftUI

struct AppStorageBasic: View {
    
    @State var generalName: String?
    
    //App Storage를 사용하면 앱을 다시 열때 자동으로 키에서 이름을 가져온다.
    @AppStorage("name") var appStorageName: String?
    
    var body: some View {
        VStack {
            VStack (spacing: 10) {
                Text("@State로 저장")
                    .font(.headline)
                
                Text(generalName ?? "당신의 이름은?")
                
                Button(action: {
                    generalName = "Sijong"
                }, label: {
                    Text("이름 불러오기")
                })
            }
            .padding()
            .border(.green)
            
            VStack (spacing: 10) {
                Text("@AppStorage로 저장")
                    .font(.headline)
                
                Text(appStorageName ?? "당신의 이름은?")
                
                Button(action: {
                    appStorageName = "Sijong"
                }, label: {
                    Text("이름 불러오기")
                })
            }
            .padding()
            .border(.orange)
        }
    }
}

#Preview {
    AppStorageBasic()
}
