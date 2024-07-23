//
//  FruitModel.swift
//  SwiftUIBasic
//
//  Created by 김시종 on 7/23/24.
//

import Foundation


struct FruitModel: Identifiable {
    let id: String = UUID().uuidString
    let name: String
    let count: Int
}
