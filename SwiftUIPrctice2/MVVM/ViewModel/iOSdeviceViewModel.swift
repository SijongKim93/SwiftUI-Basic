//
//  iOSdeviceViewModel.swift
//  SwiftUIBasic
//
//  Created by 김시종 on 7/23/24.
//

import Foundation


class iOSDeviceViewModel: ObservableObject {
    
    @Published var iOSDeviceArray: [iOSdeviceModel] = []
    
    init() {
        getData()
    }
    
    func getData() {
        let iphone = iOSdeviceModel(name: "아이폰")
        let iPad = iOSdeviceModel(name: "아이패드")
        let iMac = iOSdeviceModel(name: "아이맥")
        let appleWatch = iOSdeviceModel(name: "애플워치")
        
        self.iOSDeviceArray.append(iphone)
        self.iOSDeviceArray.append(iPad)
        self.iOSDeviceArray.append(iMac)
        self.iOSDeviceArray.append(appleWatch)
    }
}
