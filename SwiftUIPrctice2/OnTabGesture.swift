//
//  OnTabGesture.swift
//  SwiftUIBasic
//
//  Created by 김시종 on 7/22/24.
//

import SwiftUI

struct OnTabGesture: View {
    
    @State var isSelected: Bool = false
    
    var body: some View {
        VStack (spacing: 40) {
            RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                .frame(height: 200)
                .foregroundColor(isSelected ? Color.green : Color.red)
            
            Button(action: {
                isSelected.toggle()
            }, label: {
                Text("1.일반적인 버튼")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(25)
            })
            
            // Ontab 1번 클릭
            Text("2. 제스쳐 한번 클릭")
                .font(.headline)
                .foregroundColor(.white)
                .frame(height: 55)
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(25)
                .onTapGesture {
                    isSelected.toggle()
                }
            
            Text("3. 제스쳐 두번 클릭")
                .font(.headline)
                .foregroundColor(.white)
                .frame(height: 55)
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(25)
                .onTapGesture(count: 2) {
                    isSelected.toggle()
                }
            
            Spacer()
        } // Vst
        .padding(40)
    }
}

#Preview {
    OnTabGesture()
}
