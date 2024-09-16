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
    private let keyboardReader = SRSensorReader(sensor: .keyboardMetrics)
    private let phoneUsageReader = SRSensorReader(sensor: .phoneUsageReport)
    
    private var availableDevices: [SRDevice] = []
    
    @Published var ambientLightData: [AmbientLightDataPoint] = []
    
    private override init() {
        super.init()
        setupReaders()
    }
    
    private func setupReaders() {
        ambientReader.delegate = self
        keyboardReader.delegate = self
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
        
        // 주기적으로 데이터 페치
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            for device in self.availableDevices {
                print("주기적으로 데이터 페치: \(device)")
                self.fetchAmbientLightData(for: device)
            }
        }
    }
    
    private func fetchAmbientLightData(for device: SRDevice) {
        print("조도 데이터 페치 시작")
        let fetchRequest = SRFetchRequest()
        fetchRequest.from = SRAbsoluteTime(Date().addingTimeInterval(-24 * 60 * 60).timeIntervalSinceReferenceDate)
        fetchRequest.to = SRAbsoluteTime(Date().timeIntervalSinceReferenceDate)
        fetchRequest.device = device
        
        ambientReader.fetch(fetchRequest)
    }
    
    private func displayAmbientLightData(sample: SRAmbientLightSample) {
        print("조도: \(sample.lux)")
    }
    
    // MARK: - SRSensorReaderDelegate 메서드
    
    func sensorReader(_ reader: SRSensorReader, didChange authorizationStatus: SRAuthorizationStatus) {
        switch authorizationStatus {
        case .authorized:
            print("조도 센서 데이터 접근이 허가되었습니다.")
            DispatchQueue.main.async {
                self.startRecordingAmbientLightData()
            }
        case .denied:
            print("조도 센서 데이터 접근이 거부되었거나 제한되었습니다.")
            openSetting()
        case .notDetermined:
            print("notDetermined")
        @unknown default:
            print("알 수 없는 권한 상태: \(authorizationStatus)")
        }
    }
    
    func sensorReader(_ reader: SRSensorReader, didFetch devices: [SRDevice]) {
        print("장치 페치 : \(devices.count)개")
        
        availableDevices = devices
        
        for device in devices {
            print("페치된 장치: \(device)")
            fetchAmbientLightData(for: device)
        }
    }
    
    func sensorReader(_ reader: SRSensorReader, didFetch sample: SRAmbientLightSample) {
        print("didFetch 메서드 호출됨, 조도 값: \(sample.lux.value) lux")
        DispatchQueue.main.async {
            let luxValue = sample.lux.value
            let dataPoint = AmbientLightDataPoint(timestamp: Date(), lux: Float(luxValue))
            self.ambientLightData.append(dataPoint)
            print("ambientLightData에 추가된 조도 값: \(luxValue) lux")
            
            self.displayAmbientLightData(sample: sample)
        }
    }
    
    func sensorReader(_ reader: SRSensorReader, didCompleteFetch fetchRequest: SRFetchRequest) {
        print("데이터 페치 완료")
    }

    func sensorReader(_ reader: SRSensorReader, fetchDevicesDidFailWithError error: Error) {
        print("데이터 페치 실패: \(error.localizedDescription)")
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





