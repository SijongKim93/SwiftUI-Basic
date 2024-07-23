//
//  UserModelBasicView.swift
//  SwiftUIBasic
//
//  Created by 김시종 on 7/23/24.
//

import SwiftUI

struct UserModelBasicView: View {
    
    @State var users: [UserModel] = [
        UserModel(displayName: "철수", userName: "철수123", followCount: 100, isChecked: true),
        UserModel(displayName: "영희", userName: "영희사랑", followCount: 55, isChecked: false),
        UserModel(displayName: "길동", userName: "홍길동", followCount: 300, isChecked: false),
        UserModel(displayName: "한나", userName: "황한나", followCount: 80, isChecked: true)
    ]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(users) { user in
                    HStack(spacing: 20) {
                        Circle()
                            .frame(width: 35, height: 35)
                        
                        VStack (alignment: .leading, spacing: 5) {
                            Text(user.displayName)
                                .font(.headline)
                            
                            Text("@\(user.userName)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        } //: VShack
                        
                        Spacer()
                        
                        if user.isChecked {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.blue)
                        }
                        
                        VStack {
                            Text("\(user.followCount)")
                                .font(.headline)
                            Text("Followers")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                    } //: HStack
                } //: Loop
            } //: List
        } //: Navi
    }
}

#Preview {
    UserModelBasicView()
}
