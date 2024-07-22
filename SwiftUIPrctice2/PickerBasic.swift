//
//  PickerBasic.swift
//  SwiftUIBasic
//
//  Created by 김시종 on 7/22/24.
//

import SwiftUI

struct PickerBasic: View {
    
    let typeOfPhone: [String] = [
        "삼성", "애플", "샤오미", "기타 브랜드"
    ]
    
    @State var selectedIndex: Int = 0
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker(selection: $selectedIndex) {
                        ForEach(0..<typeOfPhone.count, id: \.self) { index in
                            Text(typeOfPhone[index])
                        }
                    } label: {
                        Text("기종선택")
                    }
                    .pickerStyle(.navigationLink)
                }
                Text("핸드폰 제조사는 \(typeOfPhone[selectedIndex])입니다.")
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(20)
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                
                
            } // Form
            .navigationTitle("현재 사용중인 핸드폰 기종은?")
            .navigationBarTitleDisplayMode(.inline)
        } // Navi
    }
}

#Preview {
    PickerBasic()
}
