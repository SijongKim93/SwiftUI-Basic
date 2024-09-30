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
    
    private override init() {
        super.init()
        setupReader()
    }
    
    func setupReader() {
        ambientReader.delegate = self
        checkAuthorizationStatus()
        fetchAmbientLightData()
    }
    
    func checkAuthorizationStatus() {
        switch ambientReader.authorizationStatus {
        case .authorized:
            print("접근 허용")
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
        fetchAmbientLightData()
    }
    
    func fetchAvailableDevices() {
        ambientReader.fetchDevices()
    }
    
    func fetchAmbientLightData() {
        let request = SRFetchRequest()
        
        let now = Date()
        let fromTime = now.addingTimeInterval(-6 * 24 * 60 * 60)
        let toTime = now.addingTimeInterval(-24 * 60 * 60)
        
        request.from = SRAbsoluteTime(fromTime.timeIntervalSinceReferenceDate)
        request.to = SRAbsoluteTime(toTime.timeIntervalSinceReferenceDate)
        
        for device in availableDevices {
            request.device = device
            print("\(device.name)에서 조도 데이터를 가져옵니다.")
            ambientReader.fetch(request)
        }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .long
        formatter.timeZone = TimeZone.current
        
        let fromTimeString = formatter.string(from: fromTime)
        let toTimeString = formatter.string(from: toTime)
        
        print("\(fromTimeString) ~ \(toTimeString)")
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
        
        let timestamp = Date(timeIntervalSinceReferenceDate: result.timestamp.rawValue)
        
        if let ambientSample = result.sample as? SRAmbientLightSample {
            let luxValue = ambientSample.lux.value
            let dataPoint = AmbientLightDataPoint(timestamp: timestamp, lux: Float(luxValue))
            
            DispatchQueue.main.async {
                self.ambientLightData.append(dataPoint)
                print("새로운 Ambient Light 데이터 추가됨: \(luxValue) lux, \(timestamp)")
            }
        }
        return true
    }
    
    private func saveToUserDefaults(_ dataPoint: AmbientLightDataPoint) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(dataPoint) {
            UserDefaults.standard.set(encoded, forKey: "LatestAmbientLightData")
            print("조도 데이터 UserDefaults에 저장됨")
        }
    }
    
    // 데이터 페치 완료
    func sensorReader(_ reader: SRSensorReader, didCompleteFetch fetchRequest: SRFetchRequest) {
        print("didCompleteFetch 조도 데이터 페치 완료")
    }
    
    
    // 기록 시작 성공
    func sensorReaderWillStartRecording(_ reader: SRSensorReader) {
        print("WillStartRecording 조도 데이터 기록 시작됨")
    }
    
    // 기록 중단 성공
    func sensorReaderDidStopRecording(_ reader: SRSensorReader) {
        print("조도 데이터 기록 중단됨")
    }
    
    // 기록 시작 실패
    func sensorReader(_ reader: SRSensorReader, startRecordingFailedWithError error: Error) {
        print("조도 데이터 기록 시작 실패: \(error.localizedDescription)")
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
