//
//  iOSDeviceView3.swift
//  SwiftUIBasic
//
//  Created by 김시종 on 7/23/24.
//

import SwiftUI

struct iOSDeviceView3: View {
    
    // @StateObject에서 선언한 viewModel를 @EnviromentObject를 통해 가져오기
    @EnvironmentObject var viewModel: iOSDeviceViewModel
    
    var body: some View {
        ZStack {
            Color.cyan.ignoresSafeArea()
            
            ScrollView {
                VStack (spacing: 20) {
                    ForEach(viewModel.iOSDeviceArray) { item in
                        Text(item.name)
                    }
                }
                .foregroundColor(.white)
                .font(.largeTitle)
                
            }
        }
        // 라운디드렉탱글 연습
    }
}

#Preview {
    iOSDeviceView3()
        .environmentObject(iOSDeviceViewModel())
}
