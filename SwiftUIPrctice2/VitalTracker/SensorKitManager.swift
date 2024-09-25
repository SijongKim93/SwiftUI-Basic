//
//  SensorKitManager.swift
//  VitalTracker
//
//  Created by SiJongKim on 9/11/24.
//

import Foundation
import SensorKit
import UIKit

enum SensorType {
    case ambientLight
    case phoneUsage
    case keyboardMetrics
}

final class SensorKitManager: NSObject, ObservableObject, SRSensorReaderDelegate {

    static let shared = SensorKitManager()

    private let ambientReader = SRSensorReader(sensor: .ambientLightSensor)
    private let phoneUsageReader = SRSensorReader(sensor: .phoneUsageReport)
    private let keyboardMetricsReader = SRSensorReader(sensor: .keyboardMetrics)
    
    
    @Published var ambientLightData: [AmbientLightDataPoint] = []
    @Published var totalIncomingCalls = 0
    @Published var totalOutcomingCalls = 0
    @Published var totalCallDuration: TimeInterval = 0
    @Published var uniqueContacts: Set<String> = []
    
    var availableDevices: [SRDevice] = []
    var isFetching = false
    var isRecording = false

    private override init() {
        super.init()
        setupReaders()
        checkAndRequestAuthorization(for: .ambientLight)
    }

    private func setupReaders() {
        ambientReader.delegate = self
    }

    // MARK: - 권한 설정
    
    func requestAuthorization(for sensor: SensorType) {
        let sensors: Set<SRSensor> = {
            switch sensor {
            case .ambientLight:
                return [.ambientLightSensor]
            case .keyboardMetrics:
                return [.keyboardMetrics]
            case .phoneUsage:
                return [.phoneUsageReport]
            }
        }()
        
        SRSensorReader.requestAuthorization(sensors: sensors) { [weak self] error in
            DispatchQueue.main.async {
                guard let self = self else {
                    print("권한 요청 중단")
                    return
                }
                
                if let error = error {
                    print("권한 요청 실패: \(error.localizedDescription)")
                } else {
                    print("권한 요청 성공")
                    self.startRecording(for: sensor)
                }
            }
        }
    }
    
    func checkAndRequestAuthorization(for sensor: SensorType) {
        let reader: SRSensorReader = {
            switch sensor {
            case .ambientLight:
                return ambientReader
            case .phoneUsage:
                return phoneUsageReader
            case .keyboardMetrics:
                return keyboardMetricsReader
            }
        }()
        
        let status = reader.authorizationStatus
        switch status {
        case .authorized:
            print("\(sensor) 접근 허용 됨")
            
        case .notDetermined:
            print("\(sensor) 접근 미결정, 요청 시작")
            
        case .denied:
            print("\(sensor)에 대한 접근 거부 또는 제한")
        @unknown default:
            print("알 수 없는 권한 상태")
        }
    }

    // MARK: - 데이터 기록 로직
    
    func startRecording(for sensor: SensorType) {
        guard !isRecording else {
            print("이미 데이터 기록 중입니다.")
            return
        }
        print("\(sensor) 데이터 기록 시작")
        isRecording = true
        
        switch sensor {
        case .ambientLight:
            ambientReader.startRecording()
            fetchData(for: .ambientLight)
        case .keyboardMetrics:
            keyboardMetricsReader.startRecording()
            fetchData(for: .keyboardMetrics)
        case .phoneUsage:
            phoneUsageReader.startRecording()
            fetchData(for: .phoneUsage)
        }
    }
    
    func fetchData(for sensor: SensorType) {
        print("\(sensor) 데이터 가져오기")
        let request = SRFetchRequest()
        
        let now = Date()
        let fromTime = now.addingTimeInterval(-72 * 60 * 60)
        let toTime = now.addingTimeInterval(-24 * 60 * 60)
        
        request.from = SRAbsoluteTime(fromTime.timeIntervalSinceReferenceDate)
        request.to = SRAbsoluteTime(toTime.timeIntervalSinceReferenceDate)
        
        switch sensor {
        case .ambientLight:
            ambientReader.fetch(request)
        case .keyboardMetrics:
            keyboardMetricsReader.fetch(request)
        case .phoneUsage:
            phoneUsageReader.fetch(request)
        }
    }

    // MARK: - 데이터 처리 로직
    
    private func processAmbientLightData(sample: SRAmbientLightSample, timesamp: Date) {
        let luxValue = sample.lux.value
        
        if !ambientLightData.contains(where: { $0.timestamp == timesamp }) {
            let dataPoint = AmbientLightDataPoint(timestamp: timesamp, lux: Float(luxValue))
            ambientLightData.append(dataPoint)
            print("ambientData 추가 \(luxValue) lux, \(timesamp)")
        } else {
            print("중복된 데이터로 추가하지 않음")
        }
    }
    

    
    
    
    // MARK: - Device값 로직
    
    private func fetchAmbientDeviceData() {
        print("디바이스 정보 페치 시작")
        let request = SRFetchRequest()
        
        let now = Date()
        let fromDate = now.addingTimeInterval(-72 * 60 * 60)
        let toDate = now.addingTimeInterval(-24 * 60 * 60)
        
        request.from = SRAbsoluteTime(fromDate.timeIntervalSinceReferenceDate)
        request.to = SRAbsoluteTime(toDate.timeIntervalSinceReferenceDate)
        
        if availableDevices.isEmpty {
            print("디바이스 없음")
            ambientReader.fetchDevices()
        } else {
            for device in availableDevices {
                print("데이터 페치 시작 (디바이스: \(device))")
                request.device = device
                ambientReader.fetch(request)
                print("페치 요청 보냄 (디바이스: \(device))")
            }
        }
    }
    
    // MARK: - SRSensorReaderDelegate 메서드
    
    func sensorReader(_ reader: SRSensorReader, didFetch devices: [SRDevice]) {
        availableDevices = devices
        
        for device in devices {
            print("페치된 장치: \(device)")
        }
        
        if !devices.isEmpty {
            fetchAmbientDeviceData()
        }
    }
    
    func sensorReader(_ reader: SRSensorReader, fetching fetchRequest: SRFetchRequest, didFetchResult result: SRFetchResult<AnyObject>) -> Bool {
        print("sensorReader(_:fetching:didFetchResult:) 메서드 호출됨")
        
        if let ambientSample = result.sample as? SRAmbientLightSample {
            let luxValue = ambientSample.lux.value
            let timestamp = Date(timeIntervalSinceReferenceDate: result.timestamp.rawValue)
            
            // 중복된 데이터가 있는지 확인하고 추가
            if !ambientLightData.contains(where: { $0.timestamp == timestamp }) {
                let dataPoint = AmbientLightDataPoint(timestamp: timestamp, lux: Float(luxValue))
                ambientLightData.append(dataPoint)
                print("ambientLightData에 추가된 조도 값: \(luxValue) lux, Timestamp: \(timestamp)")
            } else {
                print("중복된 데이터이므로 추가하지 않음: Timestamp: \(timestamp)")
            }
            
            // 데이터 출력
            self.displayAmbientLightData(sample: ambientSample)
        }
        
        return true
    }
    
    func sensorReader(_ reader: SRSensorReader, didCompleteFetch fetchRequest: SRFetchRequest) {
        print("데이터 페치 완료")
        
        if ambientLightData.isEmpty {
            print("24시간 이내의 조도 데이터가 없습니다.")
        } else {
            print("ambientLightData 업데이트 완료")
            for dataPoint in ambientLightData {
                print("추가된 조도 값: \(dataPoint.lux) lux, Timestamp: \(dataPoint.timestamp)")
            }
        }
    }

    func sensorReader(_ reader: SRSensorReader, fetching fetchRequest: SRFetchRequest, failedWithError error: Error) {
        print("페치 요청 실패: \(error.localizedDescription)")
        if let srError = error as? SRError {
            print("에러 코드: \(srError.code)")
        }
    }
    
    func sensorReaderWillStartRecording(_ reader: SRSensorReader) {
        print("레코딩 시작됨")
    }
    
    func sensorReaderDidStopRecording(_ reader: SRSensorReader) {
        print("조도 데이터 기록 중단됨")
        isRecording = false
    }
    
    func sensorReader(_ reader: SRSensorReader, startRecordingFailedWithError error: Error) {
        print("레코딩 시작 실패: \(error.localizedDescription)")
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

