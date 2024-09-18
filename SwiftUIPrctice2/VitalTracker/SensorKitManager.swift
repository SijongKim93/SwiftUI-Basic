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
        fetchAmbientLightData()
    }
    
    private func fetchAmbientLightData() {
        print("조도 데이터 페치 시작")
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
    
    
    private func displayAmbientLightData(sample: SRAmbientLightSample) {
        print("조도: \(sample.lux.value) lux")
        
        // ambientLightData 배열의 전체 내용을 추가로 출력
        print("현재 ambientLightData 내용:")
        for data in ambientLightData {
            print("Timestamp: \(data.timestamp), Lux: \(data.lux)")
        }
    }
    
    private func saveAmbientLightData() {
        if let encodedData = try? JSONEncoder().encode(ambientLightData) {
            UserDefaults.standard.set(encodedData, forKey: "AmbientLightData")
            print("조도 데이터 저장 완료")
        } else {
            print("조도 데이터 저장 실패")
        }
    }
     
    private func loadAmbientLightData() {
        if let savedData = UserDefaults.standard.data(forKey: "AmbientLightData"),
           let savedDataPoints = try? JSONDecoder().decode([AmbientLightDataPoint].self, from: savedData) {
            ambientLightData = savedDataPoints
            print("저장된 조도 데이터 로드 완료: \(ambientLightData)")
        } else {
            print("저장된 조도 데이터가 없습니다.")
        }
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
        }
        
        if !devices.isEmpty {
            fetchAmbientLightData()
        }
    }
    
    func sensorReader(_ reader: SRSensorReader, fetching fetchRequest: SRFetchRequest, didFetchResult result: SRFetchResult<AnyObject>) -> Bool {
        print("didFetchResult 메서드 호출됨")
        
        // result.sample을 SRAmbientLightSample으로 캐스팅
        if let ambientSample = result.sample as? SRAmbientLightSample {
            print("didFetchResult 샘플: 조도 값 = \(ambientSample.lux.value) lux")
            DispatchQueue.main.async {
                let luxValue = ambientSample.lux.value
                let dataPoint = AmbientLightDataPoint(timestamp: Date(), lux: Float(luxValue))
                self.ambientLightData.append(dataPoint)
                print("ambientLightData에 추가된 조도 값: \(luxValue) lux")
                
                self.displayAmbientLightData(sample: ambientSample)
                
                self.saveAmbientLightData()
            }
        } else {
            print("다른 타입의 샘플이 페치됨: \(type(of: result.sample))")
        }
        
        return true // 추가 처리가 필요 없음을 나타냅니다.
    }
    
    
    func sensorReader(_ reader: SRSensorReader, didCompleteFetch fetchRequest: SRFetchRequest) {
        print("데이터 페치 완료")
        
        if ambientLightData.isEmpty {
            loadAmbientLightData()
        } else {
            print("페치된 조도 데이터가 있습니다.")
        }
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





