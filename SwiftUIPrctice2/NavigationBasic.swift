//
//  NavigationBasic.swift
//  SwiftUIBasic
//
//  Created by 김시종 on 7/21/24.
//

import SwiftUI

struct NavigationBasic: View {
    
    @State var showSheet: Bool = false
    
    
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink {
                    SecondNavigationView()
                } label: {
                    Text("Second Navi 이동")
                        .foregroundColor(.white)
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }

            } //VSkack
            
            .navigationTitle("페이지 제목")
            .navigationBarTitleDisplayMode(.automatic)
            //.navigationBarHidden(false)
            
            .navigationBarItems(
                leading: Image(systemName: "line.3.horizontal"),
                trailing: Button(action: {
                    showSheet.toggle()
                }, label: {
                    Image(systemName: "gear")
                }))
        }
        .sheet(isPresented: $showSheet, content: {
            ZStack {
                Color.green.ignoresSafeArea()
                
                Text("설정페이지 입니다.")
                    .font(.largeTitle)
            }
        })
    }
}

#Preview {
    NavigationBasic()
}
