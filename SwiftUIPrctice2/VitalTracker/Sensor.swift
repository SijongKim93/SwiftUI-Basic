//
//  Sensor.swift
//  VitalTracker
//
//  Created by Jade Yoo on 2023/07/10.
//

import Foundation
import SensorKit

// MARK: - Gps Model
struct Gps: Encodable, Identifiable {
    let id = UUID()
    var timeStamp: Double
    var latitude: Float
    var longitude: Float
    var altitude: Float
    var deviceName: String
}

// MARK: - Accelerometer Model
struct Accelerometer: Encodable, Identifiable {
    let id = UUID()
    var timeStamp: Double
    var x: Float
    var y: Float
    var z: Float
    var magnitude: Float
    var deviceName: String
    
    init(timeStamp: Double, x: Float, y: Float, z: Float, magnitude: Float, deviceName: String) {
        self.timeStamp = timeStamp
        self.x = x
        self.y = y
        self.z = z
        self.magnitude = sqrt(x * x + y * y + z * z)
        self.deviceName = deviceName
    }
}

// MARK: - Pressure Data Model
struct PressureData: Encodable, Identifiable {
    let id = UUID()
    var timeStamp: Double
    var pressure: Double
    var deviceName: String
}

// MARK: - Battery Model
struct Battery: Encodable, Identifiable {
    let id = UUID()
    var timeStamp: Double
    var level: Float
    var state: String
    var deviceName: String
}

// MARK: - CallLog Model
struct CallLogDataPoint: Identifiable, Encodable {
    var id = UUID()
    let timestamp: Double
    let totalIncomingCalls: Int
    let totalOutgoingCalls: Int
    let totalCallDuration: TimeInterval
    let uniqueContacts: Int
    var deviceName: String
}


// MARK: - AmbientLight Model
struct AmbientLightDataPoint: Identifiable, Encodable {
    var id = UUID()
    let timestamp: Double
    let lux: Float
    var deviceName: String
}

// MARK: - KeyboardLog Model
struct KeyboardMetricsDataPoint: Identifiable, Encodable {
    var id = UUID()
    let timestamp: Double
    let totalWords: Int
    let totalTaps: Int
    let totalDrags: Int
    let totalDeletions: Int
    let typingSpeed: Double
    var deviceName: String
}

// MARK: - AppUsageLog Model
struct AppUsageDataPoint: Identifiable, Encodable {
    var id = UUID()
    let timestamp: Double
    let appName: String
    let usageDuration: TimeInterval
    let category: String
    let notificationCount: Int
    let webUsageDuration: TimeInterval
    var deviceName: String
}

enum DeviceUsageCategory: String, CaseIterable, Identifiable {
    case productivity = "Productivity"
    case utilities = "Utilities"
    case entertainment = "Entertainment"
    case business = "Business"
    case education = "Education"
    case music = "Music"
    case unknown = "Unknown"
    
    var id: String { self.rawValue }
}

// MARK: - DeviceUsageSummary Model
struct DeviceUsageSummary: Identifiable, Encodable {
    var id = UUID()
    let timestamp: Double
    let screenWakes: Int
    let unlocks: Int
    let unlockDuration: TimeInterval
    var deviceName: String
}

// MARK: - NotificationUsage Model
struct NotificationUsageDataPoint: Identifiable, Encodable {
    var id = UUID()
    let timestamp: Double
    let appName: String
    let event: Int
    var deviceName: String
    
    func eventDescription() -> String {
        switch event {
        case 0:
            return "알림 수신"
        case 1:
            return "알림 무시"
        case 2:
            return "알림 열림"
        default:
            return "알 수 없는 이벤트"
        }
    }
}

// MARK: - TelephonySpeechMetrics Model
struct TelephonySpeechMetricsDataPoint: Identifiable, Encodable {
    var id = UUID()
    let sessionIdentifier: String
    let sessionFlagsDescription: String
    let timestamp: Double
    let audioLevel: Double?
    let speechRecognitionResult: String?
    let speechExpressionDescription: String
    var deviceName: String
    
    enum CodingKeys: String, CodingKey {
        case id, sessionIdentifier, sessionFlagsDescription, timestamp, audioLevel, speechRecognitionResult, speechExpressionDescription, deviceName
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(sessionIdentifier, forKey: .sessionIdentifier)
        try container.encode(sessionFlagsDescription, forKey: .sessionFlagsDescription)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(audioLevel ?? 0.0, forKey: .audioLevel)
        try container.encode(speechRecognitionResult ?? "No Recognition Result", forKey: .speechRecognitionResult)
        try container.encode(speechExpressionDescription, forKey: .speechExpressionDescription)
        try container.encode(deviceName, forKey: .deviceName)
    }
}

