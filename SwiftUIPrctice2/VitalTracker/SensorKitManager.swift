//
//  AmbientManager.swift
//  VitalTracker
//
//  Created by SiJongKim on 9/27/24.
//

import UIKit
import SensorKit

class AmbientManager: NSObject, ObservableObject, SRSensorReaderDelegate {
    static let shared = AmbientManager()
    
    private let ambientReader = SRSensorReader(sensor: .ambientLightSensor)
    
    @Published var ambientLightData: [AmbientLightDataPoint] = []
    var availableDevices: [SRDevice] = []
    
    private var lastSavedTimestamp: Date?
    
    private override init() {
        super.init()
        setupReader()
    }
    
    func setupReader() {
        ambientReader.delegate = self
        checkAuthorizationStatus()
    }
    
    func checkAuthorizationStatus() {
        switch ambientReader.authorizationStatus {
        case .authorized:
            print("SensorKit 접근 허용")
            startRecording()
        case .notDetermined:
            print("권한 미결정")
            requestAuthorization()
        case .denied:
            print("권한 거부")
        @unknown default:
            print("알 수 없음")
        }
    }
    
    func requestAuthorization() {
        SRSensorReader.requestAuthorization(
            sensors: [.ambientLightSensor]) { (error: Error?) in
                if let error = error {
                    fatalError("Sensor 권한 실패")
                } else {
                    print("권한 설정 완료")
                }
            }
    }
    
    func startRecording() {
        ambientReader.startRecording()
        fetchAvailableDevices()
    }
    
    func fetchAvailableDevices() {
        ambientReader.fetchDevices()
    }
    
    func fetchAmbientLightData() {
        guard !availableDevices.isEmpty else {
            print("디바이스가 없음, 데이터를 페치할 수 없습니다.")
            return
        }
        
        let request = SRFetchRequest()
        
        let now = CFAbsoluteTimeGetCurrent()
        let fromTime = now - (7 * 24 * 60 * 60)
        let toTime = now
        
        request.from = SRAbsoluteTime.fromCFAbsoluteTime(_cf: fromTime)
        request.to = SRAbsoluteTime.fromCFAbsoluteTime(_cf: toTime)
        
        for device in availableDevices {
            request.device = device
            print("\(device.name)에서 조도 데이터를 가져옵니다.")
            ambientReader.fetch(request)
        }
    }
    
    private func filterDataByTimeInterval(_ data: [AmbientLightDataPoint], interval: TimeInterval, limit: Int) -> [AmbientLightDataPoint] {
        var filteredData: [AmbientLightDataPoint] = []
        var currentIntervalStart: Date? = nil
        var currentIntervalData: [AmbientLightDataPoint] = []
        
        for dataPoint in data {
            if let intervalStart = currentIntervalStart {
                if dataPoint.timestamp.timeIntervalSince(intervalStart) < interval {
                    currentIntervalData.append(dataPoint)
                } else {
                    filteredData.append(contentsOf: currentIntervalData.prefix(limit))
                    currentIntervalStart = dataPoint.timestamp
                    currentIntervalData = [dataPoint]
                }
            } else {
                currentIntervalStart = dataPoint.timestamp
                currentIntervalData.append(dataPoint)
            }
        }
        
        // 마지막 시간대 데이터 추가
        filteredData.append(contentsOf: currentIntervalData.prefix(limit))
        
        return filteredData
    }


    // MARK: - SRSensorReaderDelegate 메서드
    
    // 기기 정보 페치 성공
    func sensorReader(_ reader: SRSensorReader, didFetch devices: [SRDevice]) {
        self.availableDevices = devices
        for device in devices {
            print("사용 가능한 디바이스: \(device.name)")
        }
        
        if !devices.isEmpty {
            fetchAmbientLightData()
        } else {
            print("사용 가능한 디바이스가 없습니다.")
        }
    }
    
    // 데이터 페치 성공
    func sensorReader(_ reader: SRSensorReader, fetching fetchRequest: SRFetchRequest, didFetchResult result: SRFetchResult<AnyObject>) -> Bool {
        print("didFetchResult 호출")
        
        let absoluteTime = result.timestamp.toCFAbsoluteTime()
        let timestamp = Date(timeIntervalSinceReferenceDate: absoluteTime)
        
        // 1시간 단위로 데이터를 저장하도록 제어
        if let lastTimestamp = lastSavedTimestamp {
            let timeDifference = timestamp.timeIntervalSince(lastTimestamp)
            if timeDifference < 3600 {
                print("데이터 추가 안됨: 1시간 내의 데이터는 무시")
                return false
            }
        }
        
        if ambientLightData.count >= 5 {
            print("5개 데이터 페치 완료")
            return false
        }
        
        if let ambientSample = result.sample as? SRAmbientLightSample {
            let luxValue = ambientSample.lux.value
            let placement = ambientSample.placement
            
            let dataPoint = AmbientLightDataPoint(timestamp: timestamp, lux: Float(luxValue), placement: placement)
            
            DispatchQueue.main.async {
                if self.ambientLightData.count < 5 {
                    self.ambientLightData.append(dataPoint)
                    self.lastSavedTimestamp = timestamp
                    print("Ambient Light 데이터 추가됨: \(luxValue) lux, \(timestamp), \(placement)")
                } else {
                    print("5개 데이터 저장 완료")
                }
            }
        } else {
            print("페치된 샘플이 SRAmbientLightSample 형식이 아닙니다.")
        }
        return true
    }
    
    // 데이터 페치 완료
    func sensorReader(_ reader: SRSensorReader, didCompleteFetch fetchRequest: SRFetchRequest) {
        print("didCompleteFetch 조도 데이터 페치 완료")
        if ambientLightData.isEmpty {
            print("페치된 조도 데이터가 없습니다.")
        }
    }
    
    
    func sensorReader(_ reader: SRSensorReader, fetching fetchRequest: SRFetchRequest, failedWithError error: Error) {
        print("조도 데이터 페치 실패: \(error.localizedDescription)")
        if let srError = error as? SRError {
            switch srError.code {
            case .invalidEntitlement:
                print("Invalid entitlement: The app lacks the required entitlement.")
            default:
                print("Other SensorKit error: \(srError.code)")
            }
        }
    }
}
