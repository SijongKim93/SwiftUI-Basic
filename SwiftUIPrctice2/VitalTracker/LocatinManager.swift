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
    
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkAuthorizationStatus()
    }
}
    
