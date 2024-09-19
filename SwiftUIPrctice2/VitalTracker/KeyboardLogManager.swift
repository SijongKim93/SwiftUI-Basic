//
//  KeyboardLogManager.swift
//  SwiftUIBasic
//
//  Created by 김시종 on 9/20/24.
//

import Foundation
import SensorKit
import UIKit

final class KeyboardLogManager: NSObject, ObservableObject, SRSensorReaderDelegate {
    
    static let shared = KeyboardLogManager()
    
    private let keyboardReader = SRSensorReader(sensor: .keyboardMetrics)
    
    @Published var keyboardMetricsData: [KeyboardMetricsDataPoint] = []
    
    private override init() {
        super.init()
        setupReader()
        checkAndRequestAuthorization()
    }
    
    private func setupReader() {
        keyboardReader.delegate = self
    }
    
    // MARK: - 권한 요청
    
    func requestAuthorization() {
        SRSensorReader.requestAuthorization(sensors: [.keyboardMetrics]) { [weak self] error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let error = error {
                    print("권한 요청 실패: \(error.localizedDescription)")
                    if (error as NSError).code == SRError.promptDeclined.rawValue {
                        print("사용자가 권한 요청을 거부했습니다.")
                    }
                } else {
                    print("권한 요청 성공")
                    self.startRecordingKeyboardMetricsData()
                }
            }
        }
    }
    
    func checkAndRequestAuthorization() {
        let status = keyboardReader.authorizationStatus
        
        switch status {
        case .authorized:
            print("키보드 메트릭스 접근 허용됨")
            startRecordingKeyboardMetricsData()
            
        case .notDetermined:
            print("키보드 메트릭스 접근 미결정, 권한 요청 시작")
            requestAuthorization()
            
        case .denied:
            print("키보드 메트릭스 접근이 거부되었습니다.")
            
        @unknown default:
            print("알 수 없는 권한 상태입니다.")
        }
    }
    
    // MARK: - 키보드 메트릭스 데이터 로깅
    
    func startRecordingKeyboardMetricsData() {
        print("키보드 메트릭스 데이터 기록 시작")
        keyboardReader.startRecording()
        fetchKeyboardMetricsData()
    }
    
    func fetchKeyboardMetricsData() {
        let fetchRequest = SRFetchRequest()
        let fromDate = Date().addingTimeInterval(-72 * 60 * 60) // 72시간 전
        let toDate = Date().addingTimeInterval(-24 * 60 * 60)  // 24시간 전
        fetchRequest.from = SRAbsoluteTime(fromDate.timeIntervalSinceReferenceDate)
        fetchRequest.to = SRAbsoluteTime(toDate.timeIntervalSinceReferenceDate)
        fetchRequest.device = SRDevice.current
        
        keyboardReader.fetch(fetchRequest)
    }
    
    // MARK: - 데이터 처리
    
    private func processKeyboardMetricsSample(sample: SRKeyboardMetrics) {
        let duration = sample.duration
        let totalWords = sample.totalWords
        let totalTaps = sample.totalTaps
        
        // 데이터를 원하는 형식으로 처리하여 배열에 저장
        let dataPoint = KeyboardMetricsDataPoint(duration: duration, totalWords: totalWords, totalTaps: totalTaps)
        keyboardMetricsData.append(dataPoint)
        
        print("키보드 메트릭스 데이터 기록: Duration: \(duration), Total Words: \(totalWords), Total Taps: \(totalTaps)")
    }
    
    // MARK: - SRSensorReaderDelegate 메서드
    
    func sensorReader(_ reader: SRSensorReader, didFetch devices: [SRDevice]) {
        print("장치 페치 완료: \(devices.count)개")
    }
    
    func sensorReader(_ reader: SRSensorReader, didCompleteFetch fetchRequest: SRFetchRequest) {
        print("키보드 메트릭스 데이터 페치 완료")
    }
    
    func sensorReader(_ reader: SRSensorReader, fetching fetchRequest: SRFetchRequest, didFetchResult result: SRFetchResult<AnyObject>) -> Bool {
        if let keyboardMetricsSample = result.sample as? SRKeyboardMetrics {
            processKeyboardMetricsSample(sample: keyboardMetricsSample)
        }
        return true
    }
    
    func sensorReader(_ reader: SRSensorReader, fetching fetchRequest: SRFetchRequest, failedWithError error: Error) {
        print("키보드 메트릭스 데이터 페치 실패: \(error.localizedDescription)")
    }
}

// 키보드 메트릭스 데이터 포인트를 저장할 구조체
struct KeyboardMetricsDataPoint {
    let duration: TimeInterval
    let totalWords: Int
    let totalTaps: Int
}

