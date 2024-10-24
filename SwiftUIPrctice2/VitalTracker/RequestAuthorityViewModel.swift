//  RequestAuthorityViewModel.swift
//  VitalTracker
//
//  Created by SiJongKim on 10/24/24.
//

import Foundation
import Combine
import CoreLocation
import EventKit
import AVFoundation
import UserNotifications
import HealthKit
import SensorKit

class RequestAuthorityViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var locationPermissionGranted = false
    @Published var calendarPermissionGranted = false
    @Published var healthPermissionGranted = false
    @Published var notificationPermissionGranted = false
    @Published var microphonePermissionGranted = false
    @Published var ambientLightPermissionGranted = false
    @Published var callLogPermissionGranted = false
    @Published var deviceUsagePermissionGranted = false
    @Published var speechMetricsPermissionGranted = false
    @Published var keyboardMetricsPermissionGranted = false
    
    private let locationManager = CLLocationManager()
    private let healthStore = HKHealthStore()
    
    private var completionHandler: (() -> Void)?
    
    override init() {
        super.init()
        locationManager.delegate = self
    }
    
    func requestPermissionsSequentially() {
        requestLocationPermission { [weak self] in
            self?.requestCalendarPermission {
                self?.requestHealthPermission {
                    self?.requestNotificationPermission {
                        self?.requestMicrophonePermission {
                            self?.requestSensorKitPermissions()
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - 권한 요청 메서드
    
    // 1. 위치 정보 권한 요청
    func requestLocationPermission(completion: @escaping () -> Void) {
        let status = locationManager.authorizationStatus
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            self.locationPermissionGranted = true
            completion() // 권한이 이미 허용된 경우에도 completion 호출
        } else {
            locationManager.requestWhenInUseAuthorization()
            completion()
        }
    }

    // CLLocationManagerDelegate - 권한 변경 시 호출
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            DispatchQueue.main.async {
                self.locationPermissionGranted = true
            }
        }
        // 권한 변경 시 completion 호출을 위해 이를 전달할 수 있도록 로직 추가
        if let completion = completionHandler {
            completion() // 권한 변경 시 completion 호출
            completionHandler = nil // 일회성으로 완료 처리
        }
    }
    
    // 2. 캘린더 권한
    func requestCalendarPermission(completion: @escaping () -> Void) {
        let eventStore = EKEventStore()
        eventStore.requestAccess(to: .event) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    self.calendarPermissionGranted = true
                }
            }
            completion()
        }
    }
    
    // 3. 건강 데이터 권한
    func requestHealthPermission(completion: @escaping () -> Void) {
        let readTypes = Set([HKObjectType.quantityType(forIdentifier: .stepCount)!,
                             HKObjectType.quantityType(forIdentifier: .heartRate)!,
                             HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!])
        
        healthStore.requestAuthorization(toShare: nil, read: readTypes) { success, error in
            if success {
                DispatchQueue.main.async {
                    self.healthPermissionGranted = true
                }
            }
            completion()
        }
    }
    
    // 4. 알림 권한
    func requestNotificationPermission(completion: @escaping () -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    self.notificationPermissionGranted = true
                }
            }
            completion()
        }
    }
    
    // 5. 마이크 권한
    func requestMicrophonePermission(completion: @escaping () -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            if granted {
                DispatchQueue.main.async {
                    self.microphonePermissionGranted = true
                }
            }
            completion()
        }
    }
    
    // 6. SensorKit 권한 요청을 순차적으로 진행
    func requestSensorKitPermissions() {
        requestAmbientLightAuthorization {
            self.requestCallLogAuthorization {
                self.requestDeviceAuthorization {
                    self.requestSpeechMetricsAuthorization {
                        self.requestKeyboardMetricsAuthorization {
                        }
                    }
                }
            }
        }
    }
    
    // SensorKit 권한 요청 로직
    func requestAmbientLightAuthorization(completion: @escaping () -> Void) {
        let ambientReader = SRSensorReader(sensor: .ambientLightSensor)
        let currentStatus = ambientReader.authorizationStatus
        
        if currentStatus == .authorized {
            DispatchQueue.main.async {
                self.ambientLightPermissionGranted = true
                self.setupReaderAndFetchData()
            }
            completion()
        } else if currentStatus == .notDetermined {
            SRSensorReader.requestAuthorization(sensors: [.ambientLightSensor]) { error in
                if error == nil {
                    DispatchQueue.main.async {
                        self.ambientLightPermissionGranted = true
                        self.setupReaderAndFetchData()
                    }
                }
                completion()
            }
        } else {
            print("Ambient Light 권한이 부여되지 않음 또는 거부됨")
            completion()
        }
    }

    func requestCallLogAuthorization(completion: @escaping () -> Void) {
        let callLogReader = SRSensorReader(sensor: .phoneUsageReport)
        let currentStatus = callLogReader.authorizationStatus
        
        if currentStatus == .authorized {
            DispatchQueue.main.async {
                self.callLogPermissionGranted = true
            }
            completion()
        } else if currentStatus == .notDetermined {
            SRSensorReader.requestAuthorization(sensors: [.phoneUsageReport]) { error in
                if error == nil {
                    DispatchQueue.main.async {
                        self.callLogPermissionGranted = true
                    }
                }
                completion()
            }
        } else {
            print("Call Log 권한이 부여되지 않음 또는 거부됨")
            completion()
        }
    }

    func requestDeviceAuthorization(completion: @escaping () -> Void) {
        let deviceUsageReader = SRSensorReader(sensor: .deviceUsageReport)
        let currentStatus = deviceUsageReader.authorizationStatus
        
        if currentStatus == .authorized {
            DispatchQueue.main.async {
                self.deviceUsagePermissionGranted = true
            }
            completion()
        } else if currentStatus == .notDetermined {
            SRSensorReader.requestAuthorization(sensors: [.deviceUsageReport]) { error in
                if error == nil {
                    DispatchQueue.main.async {
                        self.deviceUsagePermissionGranted = true
                    }
                }
                completion()
            }
        } else {
            print("Device Usage 권한이 부여되지 않음 또는 거부됨")
            completion()
        }
    }

    func requestSpeechMetricsAuthorization(completion: @escaping () -> Void) {
        let speechMetricsReader = SRSensorReader(sensor: .telephonySpeechMetrics)
        let currentStatus = speechMetricsReader.authorizationStatus
        
        if currentStatus == .authorized {
            DispatchQueue.main.async {
                self.speechMetricsPermissionGranted = true
            }
            completion()
        } else if currentStatus == .notDetermined {
            SRSensorReader.requestAuthorization(sensors: [.telephonySpeechMetrics]) { error in
                if error == nil {
                    DispatchQueue.main.async {
                        self.speechMetricsPermissionGranted = true
                    }
                }
                completion()
            }
        } else {
            print("Speech Metrics 권한이 부여되지 않음 또는 거부됨")
            completion()
        }
    }

    func requestKeyboardMetricsAuthorization(completion: @escaping () -> Void) {
        let keyboardMetricsReader = SRSensorReader(sensor: .keyboardMetrics)
        let currentStatus = keyboardMetricsReader.authorizationStatus
        
        if currentStatus == .authorized {
            DispatchQueue.main.async {
                self.keyboardMetricsPermissionGranted = true
            }
            completion()
        } else if currentStatus == .notDetermined {
            SRSensorReader.requestAuthorization(sensors: [.keyboardMetrics]) { error in
                if error == nil {
                    DispatchQueue.main.async {
                        self.keyboardMetricsPermissionGranted = true
                    }
                }
                completion()
            }
        } else {
            print("Keyboard Metrics 권한이 부여되지 않음 또는 거부됨")
            completion()
        }
    }
    
    private func setupReaderAndFetchData() {
        // Ambient Light Sensor 관련 데이터 설정 및 페치
        AmbientManager.shared.setupReader()
        AmbientManager.shared.fetchAvailableDevices()
        
        // Call Log Sensor 관련 데이터 설정 및 페치
        CallLogManager.shared.setupReader()
        CallLogManager.shared.fetchAvailableDevices()
        
        // Device Usage Sensor 관련 데이터 설정 및 페치
        DeviceUsageManager.shared.setupReader()
        DeviceUsageManager.shared.fetchAvailableDevices()
        
        // Speech Metrics Sensor 관련 데이터 설정 및 페치
        SpeechMetricsManager.shared.setupReader()
        SpeechMetricsManager.shared.fetchAvailableDevices()
        
        // Keyboard Metrics Sensor 관련 데이터 설정 및 페치
        KeyboardMetricsManager.shared.setupReader()
        KeyboardMetricsManager.shared.fetchAvailableDevices()
    }

    
}
