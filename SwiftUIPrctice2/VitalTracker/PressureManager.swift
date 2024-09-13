
//
//  PressureManager.swift
//  EventKitPractice
//
//  Created by SiJongKim on 9/11/24.
//

import SwiftUI
import Combine
import CoreMotion

final class PressureManager: ObservableObject {
    
    private let motion = CMMotionManager()
    private let altimeter = CMAltimeter()
    
    @Published var pressureDataList = [PressureData]()
    
    private var cancellables = Set<AnyCancellable>()
    private var timer: AnyCancellable?
    
    
    //15분 간격으로 기압 정보 수집
    func startPressureUpdates() {
        timer = Timer.publish(every: 900, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.fetchPressureData()
            }
    }

    func fetchPressureData() {
        
        // 실제 로직
        if CMAltimeter.isRelativeAltitudeAvailable() {
            altimeter.startRelativeAltitudeUpdates(to: OperationQueue()) { data, error in
                if let error = error {
                    print("Error collecting pressure data: \(error.localizedDescription)")
                    return
                }
                
                if let altimeterData = data {
                    let pressureInKpa = altimeterData.pressure.floatValue
                    let pressureInHpa = pressureInKpa * 10.0
                    
                    if pressureInHpa >= 300.0 && pressureInHpa <= 1100.0 {
                        let time = Date()
                        let timestamp = time.toString()
                        
                        let pressureData = PressureData(timeStamp: timestamp, pressure: Double(pressureInHpa))
                        self.addPressureDataToList(data: pressureData)
                    }
                }
            }
        }
    }
    
    func addPressureDataToList(data: PressureData) {
        self.pressureDataList.append(data)
        print("Pressure Data: \(data.pressure) hPa at \(data.timeStamp)")
    }
    
    func stopPressureUpdates() {
        timer?.cancel()
        altimeter.stopRelativeAltitudeUpdates()
    }
}


extension Date {
    public func toString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSS"
        dateFormatter.timeZone = TimeZone(identifier: TimeZone.current.identifier)  // 현재 기기의 시간대
        
        return dateFormatter.string(from: self)
    }
}


struct PressureData: Identifiable {
    var id = UUID()
    let timeStamp: String
    let pressure: Double
    
    init(timeStamp: String, pressure: Double) {
        self.id = UUID()
        self.timeStamp = timeStamp
        self.pressure = pressure
    }
}
