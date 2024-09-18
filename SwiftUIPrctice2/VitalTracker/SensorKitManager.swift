//
//  SensorKitManager.swift
//  VitalTracker
//
//  Created by SiJongKim on 9/11/24.
//

import Foundation
import SensorKit
import UIKit

final class SensorKitManager: NSObject, ObservableObject, SRSensorReaderDelegate {
    
    static let shared = SensorKitManager()
    
    private let ambientReader = SRSensorReader(sensor: .ambientLightSensor)
    
    private var availableDevices: [SRDevice] = []
    
    @Published var ambientLightData: [AmbientLightDataPoint] = []
    
    private override init() {
        super.init()
        setupReaders()
        checkAndRequestAuthorization()
    }
    
    private func setupReaders() {
        ambientReader.delegate = self
    }
    
    // MARK: - 권한 설정
    
    func requestAuthorization() {
        SRSensorReader.requestAuthorization(sensors: [.ambientLightSensor]) { [weak self] error in
            DispatchQueue.main.async {
                guard let self = self else {
                    print("권한 요청 중단")
                    return
                }
                
                if let error = error {
                    print("권한 요청 실패: \(error.localizedDescription)")
                    if (error as NSError).code == SRError.promptDeclined.rawValue {
                        print("사용자 권한 거부")
                    }
                } else {
                    print("권한 요청 성공")
                    self.startRecordingAmbientLightData()
                }
            }
        }
    }
    
    func checkAndRequestAuthorization() {
        let status = ambientReader.authorizationStatus
        
        switch status {
        case .authorized:
            print("조도 센서 접근 허용됨")
            startRecordingAmbientLightData()
        case .notDetermined:
            print("조도 센서 접근 미결정, 권한 요청 시작")
            requestAuthorization()
        case .denied:
            print("조도 센서에 대한 접근 거부 또는 제한됨")
            // 필요한 경우 사용자에게 설정에서 권한을 변경하도록 안내하는 로직
        @unknown default:
            print("알 수 없는 권한 상태입니다.")
        }
    }
    
    // MARK: - 조도 값 로직
    
    func startRecordingAmbientLightData() {
        print("조도 데이터 기록 시작")
        ambientReader.startRecording()
        fetchAmbientDeviceData()
        fetchAmbientLightData()
    }
    
    private func fetchAmbientDeviceData() {
        print("디바이스 정보 페치 시작")
        let fetchRequest = SRFetchRequest()
        
        // 48시간 전부터 24시간 전까지의 데이터 요청 (대기 기간을 벗어난 데이터)
        let fromDate = Date().addingTimeInterval(-72 * 60 * 60)
        let toDate = Date().addingTimeInterval(-24 * 60 * 60)
        
        fetchRequest.from = SRAbsoluteTime(fromDate.timeIntervalSinceReferenceDate)
        fetchRequest.to = SRAbsoluteTime(toDate.timeIntervalSinceReferenceDate)
        
        if availableDevices.isEmpty {
            print("디바이스 없음")
            ambientReader.fetchDevices()
        } else {
            for device in availableDevices {
                print("데이터 페치 시작 (디바이스: \(device))")
                fetchRequest.device = device
                ambientReader.fetch(fetchRequest)
                print("페치 요청 보냄 (디바이스: \(device))")
            }
        }
    }
    
    func fetchAmbientLightData() {
        let fetchRequest = SRFetchRequest()
        fetchRequest.from = SRAbsoluteTime(Date().addingTimeInterval(-72 * 60 * 60).timeIntervalSinceReferenceDate)
        fetchRequest.to = SRAbsoluteTime(Date().addingTimeInterval(-24 * 60 * 60).timeIntervalSinceReferenceDate)
        fetchRequest.device = SRDevice.current
        
        
        ambientReader.fetch(fetchRequest)
    }
    
    private func displayAmbientLightData(sample: SRAmbientLightSample) {
        print("조도: \(sample.lux.value) lux")
        
        // ambientLightData 배열의 전체 내용을 추가로 출력
        print("현재 ambientLightData 내용:")
        for data in ambientLightData {
            print("Timestamp: \(data.timestamp), Lux: \(data.lux)")
        }
    }
    
    // MARK: - SRSensorReaderDelegate 메서드
    
    func sensorReader(_ reader: SRSensorReader, didFetch devices: [SRDevice]) {
        print("장치 페치 : \(devices.count)개")
        
        availableDevices = devices
        
        for device in devices {
            print("페치된 장치: \(device)")
        }
        
        if !devices.isEmpty {
            fetchAmbientDeviceData()
        }
    }
    
    func sensorReader(_ reader: SRSensorReader, didCompleteFetch fetchRequest: SRFetchRequest) {
        print("데이터 페치 완료")
        
        // 현재 시간 기준으로 24시간 전과 72시간 전 시간 계산
        let now = Date()
        let twentyFourHoursAgo = now.addingTimeInterval(-24 * 60 * 60)
        let seventyTwoHoursAgo = now.addingTimeInterval(-72 * 60 * 60)
        
        // 페치된 데이터 중 24시간에서 72시간 사이의 데이터만 필터링
        let filteredData = ambientLightData.filter { dataPoint in
            dataPoint.timestamp >= seventyTwoHoursAgo && dataPoint.timestamp <= twentyFourHoursAgo
        }
        
        if filteredData.isEmpty {
            print("24시간에서 72시간 사이의 조도 데이터가 없습니다.")
            // 필요한 경우 기본 데이터 추가
            DispatchQueue.main.async {
                let defaultTimestamp = twentyFourHoursAgo
                let dataPoint = AmbientLightDataPoint(timestamp: defaultTimestamp, lux: 0.0)
                self.ambientLightData.append(dataPoint)
                print("ambientLightData에 추가된 기본 조도 값: 0.0 lux, Timestamp: \(defaultTimestamp)")
            }
        } else {
            // 필터링된 데이터로 ambientLightData 업데이트
            DispatchQueue.main.async {
                self.ambientLightData = filteredData
                print("24시간에서 72시간 사이의 조도 데이터 \(filteredData.count)개를 추가했습니다.")
                // 데이터 로깅
                for dataPoint in filteredData {
                    print("추가된 조도 값: \(dataPoint.lux) lux, Timestamp: \(dataPoint.timestamp)")
                }
            }
        }
    }
    
    func sensorReader(_ reader: SRSensorReader, fetching fetchRequest: SRFetchRequest, didFetchResult result: SRFetchResult<AnyObject>) -> Bool {
        print("sensorReader(_:fetching:didFetchResult:) 메서드 호출됨")
        
        if let ambientSample = result.sample as? SRAmbientLightSample {
            print("Lux value: \(ambientSample.lux.value)")
            
            // 추가 로직
            let timestamp = Date(timeIntervalSinceReferenceDate: result.timestamp.rawValue)
            let dataPoint = AmbientLightDataPoint(timestamp: timestamp, lux: Float(ambientSample.lux.value))
            self.ambientLightData.append(dataPoint)
            self.displayAmbientLightData(sample: ambientSample)
        }
        
        return true
    }
    
    func sensorReader(_ reader: SRSensorReader, fetching fetchRequest: SRFetchRequest, failedWithError error: Error) {
        print("페치 요청 실패: \(error.localizedDescription)")
    }
    
    // MARK: - 권한 설정 창 이동
    
    func openSetting() {
        if let appSettings = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(appSettings) {
                UIApplication.shared.open(appSettings)
            }
        }
    }
}
