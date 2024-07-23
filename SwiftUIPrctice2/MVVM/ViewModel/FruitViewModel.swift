//
//  FruitViewModel.swift
//  SwiftUIBasic
//
//  Created by 김시종 on 7/23/24.
//

import Foundation


class FruitViewModel: ObservableObject {
    
    
    // published는 @state와 비슷하게 상태 값을 선언하는데 class안에서는 @Published를 사용한다.
    // @Published는 Fruit 배열의 값이 View에서 변경이 되면 FruitViewModel에서 새로운 변경사항을 알아차려서 변경해준다.
    @Published var fruitArray: [FruitModel] = []
    @Published var isLoading: Bool = false
    
    init() {
        getFruit()
    }
    
    func getFruit() {
        let fruit1 = FruitModel(name: "딸기", count: 1)
        let fruit2 = FruitModel(name: "사과", count: 2)
        let fruit3 = FruitModel(name: "바나나", count: 60)
        
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.fruitArray.append(fruit1)
            self.fruitArray.append(fruit2)
            self.fruitArray.append(fruit3)
            self.isLoading = false
        }
    }
    
    func deleteFruit(index: IndexSet) {
        fruitArray.remove(atOffsets: index)
    }
    
    
}
