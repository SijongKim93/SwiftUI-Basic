//
//  ActivityManager.swift
//  VitalTracker
//
//  Created by SiJongKim on 10/16/24.
//

import Foundation
import CoreLocation
import CoreMotion
import Combine

final class ActivityManager: NSObject, ObservableObject {
    
    static let shared = ActivityManager()
    
    private let motionActivityManager = CMMotionActivityManager()
    private let pedometer = CMPedometer()
    private let locationManager = CLLocationManager()
    
    @Published var activityData: [Activity] = []
    @Published var currentDistance: Double = 0.0
    @Published var totalDistance: Double = 0.0
    @Published var averageSpeed: Double = 0.0
    @Published var currentPace: Double = 0.0
    @Published var activityType: String = "Unknown"
    
    private var currentLocation: CLLocation?
    private var startDate: Date?
    
    override private init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
    }
    
    func startTracking() {
        if CMMotionActivityManager.isActivityAvailable() {
            motionActivityManager.startActivityUpdates(to: .main) { [weak self] activity in
                guard let self = self else { return }
                self.updateActivityType(activity)
            }
        }
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            startDate = Date()
        }
    }
    
    func stopTracking() {
        motionActivityManager.stopActivityUpdates()
        locationManager.stopUpdatingLocation()
    }
    
    private func updateActivityType(_ activity: CMMotionActivity?) {
        guard let activity = activity else { return }
        
        DispatchQueue.main.async {
            if activity.walking {
                self.activityType = "Walking"
            } else if activity.running {
                self.activityType = "Running"
            } else if activity.cycling {
                self.activityType = "Cycling"
            } else if activity.automotive {
                self.activityType = "Automotive"
            } else if activity.stationary {
                self.activityType = "Stationary"
            } else {
                self.activityType = "Unknown"
            }
        }
    }
    
    private func updateMetrics(from location: CLLocation) {
        if let lastLocation = currentLocation {
            let distance = location.distance(from: lastLocation)
            currentDistance += distance
            totalDistance += distance
            
            let timeInterval = location.timestamp.timeIntervalSince(startDate ?? Date())
            averageSpeed = totalDistance / timeInterval
            currentPace = timeInterval / totalDistance
        }
        currentLocation = location
    }
}

extension ActivityManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        updateMetrics(from: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}

