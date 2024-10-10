//
//  LocationManager.swift
//  VitalTracker
//
//  Created by Jade Yoo on 2023/07/06.
//

import SwiftUI
import Combine
import CoreLocation

final class LocationManager: NSObject, ObservableObject {
    static let shared = LocationManager()
    
    private let locationManager = CLLocationManager()
    
    @Published var currentLocation: Gps? = nil
    @Published var lastGpsEventDate: String = "N/A"
    
    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializer
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        // 권한 요청
        if locationManager.authorizationStatus != .authorizedAlways {
            locationManager.requestAlwaysAuthorization()
        }
        // 백그라운드 위치 수집
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
    }
    
    // MARK: - Helper functions
    
    /// 위치 정보 요청 시작
    func startRequestLocation() {
        locationManager.startUpdatingLocation()
        
        timer = Timer.scheduledTimer(withTimeInterval: 900, repeats: true) { [weak self] _ in
            print("GPS 정보 업데이트")
            self?.locationManager.startUpdatingLocation()
        }
    }
    
    /// 위치 수집 멈춤
    func stopCollectLocation() {
        locationManager.stopUpdatingLocation()
        timer?.invalidate()
    }
    
    /// 권한 상태 확인
    func checkAuthorizationStatus() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            break
        case .authorizedAlways:
            print("위치 권한 항상 허용")
            startRequestLocation()
        case .authorizedWhenInUse:
            print("위치 권한 사용하는 동안 허용")
            startRequestLocation()
        case .denied:
            print("위치 권한 거부됨")
        case .restricted:
            break
        @unknown default:
            break
        }
    }
}
    // MARK: - CLLocationManagerDelegate Methods

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        let gpsData = Gps(
            timeStamp: location.timestamp.toString(),
            latitude: Float(location.coordinate.latitude),
            longitude: Float(location.coordinate.longitude),
            altitude: Float(location.altitude)
        )
        
        DispatchQueue.main.async {
            self.currentLocation = gpsData
            self.lastGpsEventDate = location.timestamp.toReadableString()
            print("GPS 업데이트: \(self.lastGpsEventDate)")
        }
        
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("Location error: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkAuthorizationStatus()
    }
}
    
    /// 수집한 위치 정보 리스트에 추가. (Count 값 이상일때, 파일 저장 및 업로드)
    /// - Parameters:
    ///     - data: Gps 데이터
//    func addLocationDataToList(data: Gps) {
//        self.gpsDataList.append(data)
//
//        debugPrint("GPS Count: \(gpsDataList.count)/\(gpsCount) - \(data.timeStamp)")
//        // 현재 갯수를 로컬에 저장
//        realtimeGpsCount = gpsDataList.count
//
//        // 리스트의 값이 카운트 값 이상이 되면
//        if gpsDataList.count >= gpsCount && gpsCount > 0 {
//
//            // 리스트 -> Codable한 딕셔너리 -> (json)
//            var gpsDict = GpsDict()
//
//            // key - value
//            gpsDataList.forEach {
//                gpsDict[$0.timeStamp] = GPSValue(data: GPSData(latitude: "\($0.latitude)", longitude: "\($0.longitude)"))
//            }
//
//            // save as json file
//            CustomFileManager.gps.saveDataToJsonFile(data: gpsDict)
//
//            // file path
//            guard let fileURL = CustomFileManager.gps.fileURL else {
//                let errorMsg = "Invalid \(CustomFileManager.gps.field) file path..."
//                analyticsLog(title: "!INVALID_FILE_PATH", pin: pinNumber, msg: errorMsg)
//                return
//            }
//
//            // clear gps data list
//            gpsDataList = []
//
//            // upload to server
//            uploadGpsDataToServer(fileURL: fileURL)
//
//            // 데이터 업로드 시점에 Random EMA Time API 호출
//            fetchRandomEMATime()
//        }
//    }
    
    /// 저장된 JSON 파일 업로드
    /// - Parameters:
    ///     - fileURL: 파일 경로
//    func uploadGpsDataToServer(fileURL: URL) {
//        APIClient.uploadCollectedFile(userPIN: pinNumber, field: CustomFileManager.gps.field, fileUrl: fileURL)
//            .sink { completion in
//                switch completion {
//                case .finished:
//                    // delete gps file
//                    CustomFileManager.gps.deleteSentFile()
//
//                    debugPrint("DEBUG: Uploading GPS data finished")
//                case .failure(let error):
//                    // delete gps file
//                    CustomFileManager.gps.deleteSentFile()
//                    var errorMsg = ""
//                    switch error {
//                    case .http(let error):
//                        errorMsg = "\(self.pinNumber): Uploading GPS failed with \(error.body.msg)"
//
//                    case .unknown:
//                        errorMsg = "Uploading GPS failed with unknown error - \(error.localizedDescription)"
//                    }
//                    analyticsLog(title: "!GPS_UPLOAD_FAILED", pin: self.pinNumber, msg: errorMsg)
//                    print(errorMsg)
//                }
//            } receiveValue: { response in
//                let result = response.body
//                debugPrint("DEBUG: Upload GPS result - \(result.data.errorCode), \(result.msg)")
//
//                if result.data.errorCode == 0 {
//                    debugPrint("DEBUG: GPS Upload 성공")
//
//                    // firebase analytics
//                    analyticsLog(title: "GPS_DATA_UPLOADED", pin: self.pinNumber)
//                } else {
//                    print("DEBUG: GPS Upload 실패 \(result.data.errorMessage ?? "")")
//                    // firebase analytics
//                    let errorMsg = "Uploading GPS failed with \(result.data.errorMessage ?? "")"
//                    analyticsLog(title: "!GPS_UPLOAD_FAILED", pin: self.pinNumber, msg: errorMsg)
//                }
//            }
//            .store(in: &cancellables)
//    }
    
    /// EMA 랜덤하게 알림 띄우는 API
//    func fetchRandomEMATime() {
//        APIClient.fetchRandomEMATime(userPIN: pinNumber)
//            .sink { completion in
//                switch completion {
//                case .finished:
//                    debugPrint("DEBUG: Random EMA Time API call finished")
//                case .failure(let error):
//                    var errorMsg = ""
//                    switch error {
//                    case .http(let error):
//                        errorMsg = "Random EMA Time API call failed with \(error.body.msg)"
//                    case .unknown:
//                        errorMsg = "Random EMA Time API call failed with unknown error -  \(error.localizedDescription)"
//                    }
//                    analyticsLog(title: "!EMA_TIME_SET_FAILED", pin: self.pinNumber, msg: errorMsg)
//                    print(errorMsg)
//                }
//            } receiveValue: { response in
//                if response.statusCode == 200 {
//                    debugPrint("DEBUG: Fetch random EMA time 성공")
//                    // firebase analytics
//                    analyticsLog(title: "EMA_TIME_SET", pin: self.pinNumber)
//                } else {
//                    print("DEBUG: Fetch random EMA time 실패 \(response.body.msg)")
//                    // firebase analytics
//                    let errorMsg = "Random EMA Time API call failed with \(response.body.msg)"
//                    analyticsLog(title: "!EMA_TIME_SET_FAILED", pin: self.pinNumber, msg: errorMsg)
//                }
//            }
//            .store(in: &cancellables)
//    }

