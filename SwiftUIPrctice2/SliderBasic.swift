//
//  SliderBasic.swift
//  SwiftUIBasic
//
//  Created by 김시종 on 7/22/24.
//

import SwiftUI

struct SliderBasic: View {
    
    @State var slidervalue: Double = 3
    @State var color: Color = .blue
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("레발: ")
                Text("\(slidervalue)")
                Text(String(format: "%.0f", slidervalue))
            }
            .foregroundColor(color)
            //value는 항상 float Int가 아닌 float 타입으로 설정
            //in : 슬라이더의 범위 설정
            // step : 단계 설정 슬라이더가 어떤 단위로 증가 감소 되는지 설정
            
            Slider(value: $slidervalue,
                   in: 1...5,
                   step: 1.0,
                   onEditingChanged: { _ in
                color = .red
                },
                   minimumValueLabel: Text("1"),
                   maximumValueLabel: Text("5"),
                   label: {
                Text("라벨")
                })
            .accentColor(.red)
            .padding()
        }
    }
}

#Preview {
    SliderBasic()
}
