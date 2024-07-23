//
//  FruitBasicView.swift
//  SwiftUIBasic
//
//  Created by 김시종 on 7/23/24.
//

import SwiftUI

struct FruitBasicView: View {
    
    //ObservedObject 사용하여 viewmodel 객체화 하기 -> SubView에서 사용함 (부모뷰에서 값을 넘겨받을때)
    //@ObservedObject var fruitViewModel = FruitViewModel()
    
    // StateObject 사용하여 viewmodel 객체화 하기 -> View가 처음 생성되어 초기화 할때 부모뷰에서 주로 사용
    @StateObject var fruitViewModel = FruitViewModel()
    
    var body: some View {
        NavigationView {
            List {
                if fruitViewModel.isLoading {
                    ProgressView()
                } else {
                    ForEach(fruitViewModel.fruitArray) { fruit in
                        HStack {
                            Text("\(fruit.count)")
                                .foregroundColor(.red)
                            Text(fruit.name)
                                .font(.headline)
                                .bold()
                        }
                    } //:Loop
                } //: conditional
            } //:List
//            .onAppear {
//                fruitViewModel.getFruit()
//            }
            .navigationBarItems(
                trailing: NavigationLink(destination: {
                    SecondScreen(fruitViewModel: fruitViewModel)
                }, label: {
                    Image(systemName: "arrow.right")
                        .font(.title)
                }))
            .navigationTitle("과일 리스트")
        } //: Navi
    }
}


#Preview {
    FruitBasicView()
}
