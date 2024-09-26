//
//  SensorKitManager.swift
//  VitalTracker
//
//  Created by SiJongKim on 9/11/24.
//

import SensorKit
import UIKit

enum SensorType {
    case ambientLight
    case phoneUsage
    case keyboardMetrics
    //case deviceAppUsage
}

final class SensorKitManager: NSObject, ObservableObject {
    
    static let shared = SensorKitManager()
    
    private let sensorKitDataManager = SensorKitDataManager()
    
    private let ambientReader = SRSensorReader(sensor: .ambientLightSensor)
    private let phoneUsageReader = SRSensorReader(sensor: .phoneUsageReport)
    private let keyboardMetricsReader = SRSensorReader(sensor: .keyboardMetrics)
    //private let deviceUsageReader = SRSensorReader(sensor: .deviceUsageReport)
    
    private var sensorKitDelegate: SensorKitDelegate?
    
    @Published var ambientLightData: [AmbientLightDataPoint] = []
    @Published var keyboardMetricsData: [KeyboardMetricsDataPoint] = []
    @Published var phoneUsageData: [CallLogDataPoint] = []
    //@Published var categoryUsageData: [CategoryUsageData] = []
    
    var availableDevices: [SRDevice] = []
    var isFetching = false
    var isRecording = false
    
    private override init() {
        super.init()
        setupReaders()
        checkAndRequestAuthorization(for: .ambientLight)
    }
    
    private func setupReaders() {
        sensorKitDelegate = SensorKitDelegate(manager: self)
        
        let readers: [SRSensorReader] = [ambientReader, phoneUsageReader, keyboardMetricsReader] //deviceUsageReader]
        
        for reader in readers {
            reader.delegate = sensorKitDelegate
        }
    }
    
    // MARK: - 권한 설정
    
    func checkAndRequestAllAuthorizations() {
        checkAndRequestAuthorization(for: .ambientLight)
        checkAndRequestAuthorization(for: .phoneUsage)
        checkAndRequestAuthorization(for: .keyboardMetrics)
        //checkAndRequestAuthorization(for: .deviceAppUsage)
    }
    
    
    func requestAuthorization(for sensor: SensorType) {
        let sensors: Set<SRSensor> = {
            switch sensor {
            case .ambientLight:
                return [.ambientLightSensor]
            case .keyboardMetrics:
                return [.keyboardMetrics]
            case .phoneUsage:
                return [.phoneUsageReport]
                //            case .deviceAppUsage:
                //                return [.deviceUsageReport]
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
                //            case .deviceAppUsage:
                //                return deviceUsageReader
            }
        }()
        
        let status = reader.authorizationStatus
        switch status {
        case .authorized:
            print("\(sensor) 접근 허용 됨")
            startRecording(for: sensor)
        case .notDetermined:
            print("\(sensor) 접근 미결정, 요청 시작")
            requestAuthorization(for: sensor)
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
            //        case .deviceAppUsage:
            //            deviceUsageReader.startRecording()
        }
    }
    
    func fetchData(for sensor: SensorType) {
        switch sensor {
        case .ambientLight:
            // UserDefaults에서 조도 데이터를 불러오기
            let localData = sensorKitDataManager.storedAmbientLightData
            
            if localData.isEmpty {
                print("저장된 조도 데이터가 없습니다. SensorKit에서 새로운 데이터를 가져옵니다.")
                
                // SensorKit에서 조도 데이터 가져오기
                let request = SRFetchRequest()
                let now = Date()
                let fromTime = now.addingTimeInterval(-72 * 60 * 60)
                let toTime = now
                request.from = SRAbsoluteTime(fromTime.timeIntervalSinceReferenceDate)
                request.to = SRAbsoluteTime(toTime.timeIntervalSinceReferenceDate)
                ambientReader.fetch(request)
            } else {
                print("저장된 조도 데이터를 사용합니다.")
                ambientLightData = localData
            }
            
        case .keyboardMetrics:
            keyboardMetricsReader.fetch(SRFetchRequest())
        case .phoneUsage:
            phoneUsageReader.fetch(SRFetchRequest())
        }
    }

    
    // MARK: - 데이터 처리 로직
    
    func processAmbientLightData(sample: SRAmbientLightSample, timesamp: Date) {
        let luxValue = sample.lux.value
        
        if !ambientLightData.contains(where: { $0.timestamp == timesamp }) {
            let dataPoint = AmbientLightDataPoint(timestamp: timesamp, lux: Float(luxValue))
            ambientLightData.append(dataPoint)
            
            sensorKitDataManager.saveAmbientLightData(dataPoint)
            
            print("ambientData 추가")
        } else {
            print("중복된 데이터로 추가하지 않음")
        }
    }
    
    func processKeyboardMetricsData(sample: SRKeyboardMetrics, timestamp: Date) {
        let totalWords = sample.totalWords // 입력된 총 단어 수
        let totalTaps = sample.totalTaps // 총 탭 수
        let totalDrags = sample.totalDrags // 총 드래그 수
        let totalDeletions = sample.totalDeletes // 총 삭제 횟수
        let typingSpeed = sample.typingSpeed // 타이핑 속도
        
        if !keyboardMetricsData.contains(where: { $0.timestamp == timestamp }) {
            let dataPoint = KeyboardMetricsDataPoint(
                timestamp: timestamp,
                totalWords: Int(totalWords),
                totalTaps: Int(totalTaps),
                totalDrags: Int(totalDrags),
                totalDeletions: Int(totalDeletions),
                typingSpeed: typingSpeed
            )
            keyboardMetricsData.append(dataPoint)
            print("키보드 메트릭스 데이터 추가: \(totalWords) 단어, \(totalTaps) 탭, \(typingSpeed) 타이핑 속도, Timestamp: \(timestamp)")
        } else {
            print("중복된 데이터로 추가하지 않음: \(timestamp)")
        }
    }
    
    func processPhoneUsageData(sample: SRPhoneUsageReport, timestamp: Date) {
        let totalIncomingCalls = sample.totalIncomingCalls // 수신 통화 수
        let totalOutgoingCalls = sample.totalOutgoingCalls // 발신 통화 수
        let totalCallDuration = sample.totalPhoneCallDuration // 통화 시간 총합
        let totalUniqueContactsCount = sample.totalUniqueContacts // 연락처 수
        
        let dataPoint = CallLogDataPoint(
            totalIncomingCalls: totalIncomingCalls,
            totalOutgoingCalls: totalOutgoingCalls,
            totalCallDuration: totalCallDuration,
            uniqueContacts: totalUniqueContactsCount
        )
        phoneUsageData.append(dataPoint)
    }
    
    //    func processDeviceUsageReport(report: SRDeviceUsageReport) {
    //        for (categoryKey, apps) in report.applicationUsageByCategory {
    //            var appUsageList: [AppUsageData] = []
    //
    //            for app in apps {
    //                let appUsageData = AppUsageData(
    //                    bundleIdentifier: app.bundleIdentifier ?? "Unknown",
    //                    category: categoryKey.rawValue,
    //                    totalUsageTime: app.usageTime
    //                )
    //                appUsageList.append(appUsageData)
    //            }
    //
    //            let categoryUsageData = CategoryUsageData(
    //                category: categoryKey.rawValue,
    //                apps: appUsageList
    //            )
    //
    //            DispatchQueue.main.async {
    //                self.categoryUsageData.append(categoryUsageData)
    //                print("카테고리 별 앱 사용 데이터 업데이트 완료")
    //            }
    //        }
    //    }
    
    
    // MARK: - Device값 로직
    
    func fetchAmbientDeviceData() {
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
    
    // MARK: - 권한 설정 창 이동
    
    func openSetting() {
        if let appSettings = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(appSettings) {
                UIApplication.shared.open(appSettings)
            }
        }
    }
}


