//
//  ListView.swift
//  SwiftUIPrctice2
//
//  Created by 김시종 on 7/3/24.
//

import SwiftUI

// 리스트 기능 구현
struct ListView: View {
    var items = ["item1", "item2", "item3"]
    var body: some View {
        List(items, id: \.self) { item in
            Text(item)
        }
    }
}

#Preview {
    ListView()
}


