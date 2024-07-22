//
//  ContextMenuBasic.swift
//  SwiftUIBasic
//
//  Created by 김시종 on 7/21/24.
//

import SwiftUI

struct ContextMenuBasic: View {
    
    @State var statusText: String = ""
    @State var background: Color = Color.cyan
    
    var body: some View {
        VStack (spacing: 30) {
            Text(statusText)
            
            VStack(alignment: .leading, content: {
                Text("ConText Menu Test")
                    .font(.headline)
                Text("이 버튼을 길게 누르면 메뉴가 나타납니다.")
                    .font(.subheadline)
            })
            .foregroundColor(.white)
            .padding(30)
            .background(background)
            .cornerRadius(20)
            .contextMenu(ContextMenu(menuItems: {
                Button(action: {
                    statusText = "공유가 되었습니다."
                    background = .yellow
                }, label: {
                    Label(
                        title: { Text("Report post") },
                        icon: { Image(systemName: "square.and.arrow.up") }
                    )
                })
                Button(action: {
                    statusText = "좋아요 추가!"
                    background = .green
                }, label: {
                    Label(
                        title: { Text("Like post") },
                        icon: { Image(systemName: "hand.thumbsup") }
                    )
                })
                Button(action: {
                    statusText = "신고하기"
                    background = .red
                }, label: {
                    Label(
                        title: { Text("report") },
                        icon: { Image(systemName: "exclamationmark.bubble") }
                    )
                })
            }))
        }
    }
}

#Preview {
    ContextMenuBasic()
}
