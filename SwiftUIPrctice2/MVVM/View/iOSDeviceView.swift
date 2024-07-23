//
//  iOSDeviceView.swift
//  SwiftUIBasic
//
//  Created by 김시종 on 7/23/24.
//

import SwiftUI

struct iOSDeviceView: View {
    
    //처음 ViewModel을 초기화 할때는 StateObject로 불러오기
    
    @StateObject var viewModel: iOSDeviceViewModel = iOSDeviceViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.iOSDeviceArray) { item in
                    NavigationLink {
                        iOSDeviceView2(selectedItem: item.name)
                    } label: {
                        Text(item.name)
                    }
                }
            }
        }
        .environmentObject(viewModel)
    }
}

#Preview {
    iOSDeviceView()
}
