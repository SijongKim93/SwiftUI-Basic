//
//  KeyboardMetricsManager.swift
//  VitalTracker
//
//  Created by SiJongKim on 9/30/24.
//

import Foundation
import SensorKit


/**
 각 SensorKit Manager는 동일한 로직을 가지고 있어 한번에 구현이 가능하지만
 추후 모듈화해 로직을 별도로 사용할 수도 있기 때문에 일단 동일한 구조를 나눠서 구현
 */
final class KeyboardMetricsManager: NSObject, ObservableObject, SRSensorReaderDelegate {
    static let shared = KeyboardMetricsManager()
    
    private let keyboardMetricsReader = SRSensorReader(sensor: .keyboardMetrics)
    
    @Published var keyboardMetricsData: [KeyboardMetricsDataPoint] = []
    var availableDevices: [SRDevice] = []
    
    private var lastSavedTimestamp: Date?
    
    private override init() {
        super.init()
        setupReader()
    }
    
    private func setupReader() {
        keyboardMetricsReader.delegate = self
        checkAuthorizationStatus()
    }
    
    private func checkAuthorizationStatus() {
        switch keyboardMetricsReader.authorizationStatus {
        case .authorized:
            print("키보드 매트릭스 접근 허용")
            startRecording()
            print("startRecording")
        case .notDetermined:
            print("권한 미결정")
            requestAuthorization()
        case .denied:
            print("권한 거부")
        @unknown default:
            print("알 수 없음")
        }
    }
    
    private func requestAuthorization() {
        SRSensorReader.requestAuthorization(sensors: [.keyboardMetrics]) { error in
            if let error = error {
                print("키보드 매트릭스 권한 요청 실패: \(error.localizedDescription)")
            } else {
                print("권한 설정 완료")
            }
        }
    }
    
    private func startRecording() {
        keyboardMetricsReader.startRecording()
        fetchAvailableDevices()
    }
    
    private func fetchAvailableDevices() {
        keyboardMetricsReader.fetchDevices()
    }
    
    func fetchKeyboardMetricsData() {
        guard !availableDevices.isEmpty else {
            print("디바이스 없음")
            return
        }
        
        let request = SRFetchRequest()
        
        let now = CFAbsoluteTimeGetCurrent()
        let fromTime = now - (6 * 24 * 60 * 60)
        let toTime = now
        
        request.from = SRAbsoluteTime.fromCFAbsoluteTime(_cf: fromTime)
        request.to = SRAbsoluteTime.fromCFAbsoluteTime(_cf: toTime)
        
        for device in availableDevices {
            request.device = device
            print("\(device.name)에서 키보드 데이터를 가져옵니다.")
            keyboardMetricsReader.fetch(request)
        }
    }
    
    private func processKeyboardMetricsData(sample: SRKeyboardMetrics, timestamp: Date) {
        let totalWords = sample.totalWords
        let totalTaps = sample.totalTaps
        let totalDrags = sample.totalDrags
        let totalDeletions = sample.totalDeletes
        let typingSpeed = sample.typingSpeed
        
        let dataPoint = KeyboardMetricsDataPoint(
            timestamp: timestamp,
            totalWords: Int(totalWords),
            totalTaps: Int(totalTaps),
            totalDrags: Int(totalDrags),
            totalDeletions: Int(totalDeletions),
            typingSpeed: typingSpeed
        )
        
        DispatchQueue.main.async {
            self.keyboardMetricsData.append(dataPoint)
            print("키보드 메트릭스 데이터 추가됨: \(dataPoint)")
        }
    }
    
    func sensorReader(_ reader: SRSensorReader, didFetch devices: [SRDevice]) {
        self.availableDevices = devices
        for device in devices {
            print("사용 가능한 디바이스: \(device.name)")
        }
        
        if !devices.isEmpty {
            fetchKeyboardMetricsData()
        } else {
            print("사용 가능한 디바이스가 없습니다.")
        }
    }
    
    func sensorReader(_ reader: SRSensorReader, fetching fetchRequest: SRFetchRequest, didFetchResult result: SRFetchResult<AnyObject>) -> Bool {
        let timestamp = Date(timeIntervalSinceReferenceDate: result.timestamp.rawValue)
        if let keyboardMetricsSample = result.sample as? SRKeyboardMetrics {
            processKeyboardMetricsData(sample: keyboardMetricsSample, timestamp: timestamp)
        }
        return true
    }
    
    
    
    func sensorReader(_ reader: SRSensorReader, didCompleteFetch fetchRequest: SRFetchRequest) {
        print("키보드 메트릭스 데이터 페치 완료")
    }
    
    func sensorReader(_ reader: SRSensorReader, fetching fetchRequest: SRFetchRequest, failedWithError error: Error) {
        print("키보드 메트릭스 데이터 페치 실패: \(error.localizedDescription)")
    }
}
