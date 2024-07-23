//
//  UserModel.swift
//  SwiftUIBasic
//
//  Created by 김시종 on 7/23/24.
//

import Foundation


struct UserModel: Identifiable {
    let id: String = UUID().uuidString
    let displayName: String
    let userName: String
    let followCount: Int
    let isChecked: Bool
}
