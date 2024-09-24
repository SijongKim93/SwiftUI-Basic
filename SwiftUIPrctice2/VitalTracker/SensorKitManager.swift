//
//  SensorKitManager.swift
//  VitalTracker
//
//  Created by SiJongKim on 9/11/24.
//

import Foundation
import SensorKit
import UIKit
import Speech

// Encodable 익스텐션 그대로 사용
extension Encodable {
    var convertToDict: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
    }
}

// SensorKitObserver 프로토콜 정의 (callbackdelegate 사용 시 필요)
protocol SensorKitObserver: AnyObject {
    func onSensorFetch(_ event: SensorKitEvent)
}

// SensorKitEvent 구조체 정의
struct SensorKitEvent {
    let timestamp: Double
    let sensor: String
    let data: [String: Any]
}

final class SensorKitManager: NSObject, ObservableObject, SRSensorReaderDelegate {

    static let shared = SensorKitManager()

    private let ambientReader = SRSensorReader(sensor: .ambientLightSensor)
    // 다른 센서도 추가 가능
    // private let anotherSensorReader = SRSensorReader(sensor: .anotherSensor)

    @Published var ambientLightData: [AmbientLightDataPoint] = []
    var availableDevices: [SRDevice] = []

    weak var callbackdelegate: SensorKitObserver?

    var isRecordingAmbientLight = false

    private override init() {
        super.init()
        setupReader()
        checkAndRequestAuthorization()
    }

    private func setupReader() {
        ambientReader.delegate = self
        // 다른 센서 리더의 델리게이트도 설정
        // anotherSensorReader.delegate = self
    }

    // MARK: - 권한 설정

    func requestAuthorization() {
        SRSensorReader.requestAuthorization(sensors: [.ambientLightSensor /*, .anotherSensor */]) { [weak self] error in
            DispatchQueue.main.async {
                guard let self = self else {
                    print("권한 요청 중단")
                    return
                }

                if let error = error {
                    print("권한 요청 실패: \(error.localizedDescription)")
                } else {
                    print("권한 요청 성공")
                    // 권한 상태 변경은 델리게이트 메서드에서 처리
                }
            }
        }
    }

    func checkAndRequestAuthorization() {
        let status = ambientReader.authorizationStatus
        print("권한 상태: \(status.rawValue)")
        switch status {
        case .authorized:
            print("조도 센서 접근 허용됨")
            startRecordingSensors()
            fetchAvailableDevices()
        case .notDetermined:
            print("조도 센서 접근 미결정, 권한 요청 시작")
            requestAuthorization()
        case .denied:
            print("조도 센서에 대한 접근 거부 또는 제한됨")
            openSetting()
        @unknown default:
            print("알 수 없는 권한 상태입니다.")
        }
    }

    // MARK: - Device 값 로직

    private func fetchAvailableDevices() {
        print("디바이스 정보 페치 시작")
        ambientReader.fetchDevices()
        // 다른 센서 리더도 fetchDevices 호출
        // anotherSensorReader.fetchDevices()
    }

    // MARK: - 센서 데이터 로직

    func startRecordingSensors() {
        startRecordingAmbientLightData()
        // 다른 센서도 시작
        // startRecordingAnotherSensorData()
    }

    func startRecordingAmbientLightData() {
        guard !isRecordingAmbientLight else {
            print("이미 조도 데이터 기록 중입니다.")
            return
        }
        print("조도 데이터 기록 시작")
        isRecordingAmbientLight = true
        ambientReader.startRecording()
    }

    // 다른 센서의 레코딩 시작 메서드도 추가

    func fetchSensorData() {
        fetchAmbientLightData()
        // 다른 센서 데이터 페칭 메서드도 호출
        // fetchAnotherSensorData()
    }

    func fetchAmbientLightData() {
        print("조도 데이터 가져오기")
        let request = SRFetchRequest()

        let now = Date()
        let fromTime = now.addingTimeInterval(-7 * 24 * 60 * 60) // 7일 전
        let toTime = now.addingTimeInterval(-24 * 60 * 60)       // 24시간 전

        request.from = SRAbsoluteTime(fromTime.timeIntervalSinceReferenceDate)
        request.to = SRAbsoluteTime(toTime.timeIntervalSinceReferenceDate)

        print("데이터 페치 요청: \(fromTime) ~ \(toTime)")
        ambientReader.fetch(request)
    }

    // 다른 센서의 데이터 페칭 메서드도 추가

    // MARK: - SRSensorReaderDelegate 메서드

    func sensorReader(_ reader: SRSensorReader, didChange authorizationStatus: SRAuthorizationStatus) {
        print("권한 상태 변경됨: \(authorizationStatus.rawValue)")
        switch authorizationStatus {
        case .authorized:
            print("\(reader.sensor.rawValue) 센서 접근 허용됨")
            startRecordingSensors()
            fetchAvailableDevices()
        case .denied:
            print("\(reader.sensor.rawValue) 센서에 대한 접근 거부 또는 제한됨")
            openSetting()
        default:
            break
        }
    }

    func sensorReaderWillStartRecording(_ reader: SRSensorReader) {
        print("레코딩 시작 예정: \(reader.sensor.rawValue)")
    }

    func sensorReader(_ reader: SRSensorReader, startRecordingFailedWithError error: Error) {
        print("레코딩 시작 실패 (\(reader.sensor.rawValue)): \(error.localizedDescription)")
        if reader.sensor == .ambientLightSensor {
            isRecordingAmbientLight = false
        }
        // 다른 센서에 대한 처리도 추가
    }

    func sensorReaderDidStopRecording(_ reader: SRSensorReader) {
        print("\(reader.sensor.rawValue) 데이터 기록 중단됨")
        if reader.sensor == .ambientLightSensor {
            isRecordingAmbientLight = false
        }
        // 다른 센서에 대한 처리도 추가
    }

    func sensorReader(_ reader: SRSensorReader, didFetch devices: [SRDevice]) {
        availableDevices = devices

        for device in devices {
            print("페치된 장치: \(device)")
        }

        if !devices.isEmpty {
            fetchSensorData()
        } else {
            print("사용 가능한 디바이스가 없습니다.")
        }
    }

    func sensorReader(_ reader: SRSensorReader, fetching fetchRequest: SRFetchRequest, didFetchResult result: SRFetchResult<AnyObject>) -> Bool {
        print("didFetchResult 호출 (\(reader.sensor.rawValue))")
        processResult(result, sensor: reader.sensor)
        return true
    }

    func sensorReader(_ reader: SRSensorReader, didCompleteFetch fetchRequest: SRFetchRequest) {
        print("데이터 페치 완료 (\(reader.sensor.rawValue))")
        print("총 가져온 데이터 포인트 수: \(ambientLightData.count)")

        // 데이터 정렬
        DispatchQueue.main.async {
            self.ambientLightData.sort { $0.timestamp < $1.timestamp }
            print("데이터 정렬 완료")
        }
    }

    func sensorReader(_ reader: SRSensorReader, fetching fetchRequest: SRFetchRequest, failedWithError error: Error) {
        print("페치 요청 실패 (\(reader.sensor.rawValue)): \(error.localizedDescription)")
        if let srError = error as? SRError {
            print("에러 코드: \(srError.code)")
        }
    }

    // MARK: - Sensor Data Processing

    private func processResult(_ result: SRFetchResult<AnyObject>, sensor: SRSensor) {
        var sample: Encodable?
        if let lightSample = result.sample as? SRAmbientLightSample {
            sample = SRAmbientLightSampleCustom(lightSample)

            // 조도 데이터 처리
            let luxValue = lightSample.lux.value
            let timestamp = Date(timeIntervalSinceReferenceDate: result.timestamp.rawValue)
            let dataPoint = AmbientLightDataPoint(timestamp: timestamp, lux: Float(luxValue))
            DispatchQueue.main.async {
                self.ambientLightData.append(dataPoint)
            }
            print("추가된 조도 값: \(luxValue) lux, Timestamp: \(timestamp)")
        }

        guard let json = sample?.convertToDict else { return }
        let date = Date(timeIntervalSinceReferenceDate: result.timestamp.rawValue)
        let model = SensorKitEvent(timestamp: date.timeIntervalSince1970 * 1000, sensor: sensor.rawValue, data: json)
        callbackdelegate?.onSensorFetch(model)
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

// 필요한 커스텀 모델들 정의 (예시)
struct SRAmbientLightSampleCustom: Encodable {
    let lux: Double
    let chromaticity: [Double]

    init(_ sample: SRAmbientLightSample) {
        self.lux = Double(sample.lux.value)
        self.chromaticity = [Double(sample.chromaticity.x), Double(sample.chromaticity.y)]
    }
}
