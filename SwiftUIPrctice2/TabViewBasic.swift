//
//  TabViewBasic.swift
//  SwiftUIBasic
//
//  Created by 김시종 on 7/22/24.
//

import SwiftUI

struct TabViewBasic: View {
    
    @State var initPageNumber: Int = 0
    
    var body: some View {
        TabView(selection: $initPageNumber,
                content:  {
        
            HomeView(selectedTab: $initPageNumber).tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
            }
            .tag(0)
            
            Text("둘러보기").tabItem {
                Image(systemName: "globe")
                Text("Browse")
            }
            .tag(1)
            Text("프로필 화면").tabItem {
                Image(systemName: "person")
                Text("Profile")
            }
            .tag(2)
        })
    }
}

#Preview {
    TabViewBasic()
}


struct HomeView: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        ZStack {
            Color.red.edgesIgnoringSafeArea(.top)
            
            VStack(spacing: 20) {
                Text("홈 화면")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                
                Button(action: {
                    selectedTab = 2
                }, label: {
                    Text("프로필 화면 이동")
                        .font(.headline)
                        .padding(20)
                        .padding(.horizontal)
                        .background(Color.white)
                        .cornerRadius(20)
                        .foregroundColor(.red)
                })
            }
        } //: zst
    }
}
