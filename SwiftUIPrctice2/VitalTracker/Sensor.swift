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
    var timeStamp: Int64
    var latitude: Float
    var longitude: Float
    var altitude: Float
    var speed: Float
    var accuracy: Float
}

// MARK: - Accelerometer Model
struct Accelerometer: Encodable, Identifiable {
    let id = UUID()
    var timeStamp: Int64
    var x: Float
    var y: Float
    var z: Float
    
    init(timeStamp: Int64, x: Float, y: Float, z: Float) {
        self.timeStamp = timeStamp
        self.x = x
        self.y = y
        self.z = z
    }
}

// MARK: - Gyroscope Model
struct GyroscopeData: Encodable, Identifiable {
    let id = UUID()
    var timestamp: Int64
    var x: Float
    var y: Float
    var z: Float
}

// MARK: - Magnetometer Model
struct MagnetometerData: Encodable, Identifiable {
    let id = UUID()
    var timestamp: Int64
    var x: Float
    var y: Float
    var z: Float
}

// MARK: - Pressure Data Model
struct PressureData: Encodable, Identifiable {
    let id = UUID()
    var timeStamp: Int64
    var pressure: Double
}

// MARK: - Battery Model
struct Battery: Encodable, Identifiable {
    let id = UUID()
    var timeStamp: Int64
    var level: Float
    var state: String
}

// MARK: - CallLog Model
struct CallLogDataPoint: Identifiable, Encodable {
    var id = UUID()
    let timestamp: Int64
    let totalIncomingCalls: Int
    let totalOutgoingCalls: Int
    let totalCallDuration: TimeInterval
    let uniqueContacts: Int
}

// MARK: - AmbientLight Model
struct AmbientLightDataPoint: Identifiable, Encodable {
    var id = UUID()
    let timestamp: Int64
    let lux: Float
}

// MARK: - KeyboardLog Model
struct KeyboardMetricsDataPoint: Identifiable, Encodable {
    var id = UUID()
    let timestamp: Int64
    let totalWords: Int
    let totalTaps: Int
    let totalDrags: Int
    let totalDeletions: Int
    let typingSpeed: Double
}

// MARK: - AppUsageLog Model
struct AppUsageDataPoint: Identifiable, Encodable {
    var id = UUID()
    let timestamp: Int64
    let appName: String
    let usageDuration: TimeInterval
    let category: String
    let notificationCount: Int
    let webUsageDuration: TimeInterval
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
    let timestamp: Int64
    let screenWakes: Int
    let unlocks: Int
    let unlockDuration: TimeInterval
}

// MARK: - NotificationUsage Model
struct NotificationUsageDataPoint: Identifiable, Encodable {
    var id = UUID()
    let timestamp: Int64
    let appName: String
    let event: Int
    
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
    let timestamp: Int64
    let confidence: Double
    let mood: Double
    let valence: Double
    let activation: Double
    let dominance: Double
    let audioLevel: Double?  // audio level은 있음을 확인했으므로 유지

    enum CodingKeys: String, CodingKey {
        case id, timestamp, confidence, mood, valence, activation, dominance, audioLevel
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(confidence, forKey: .confidence)
        try container.encode(mood, forKey: .mood)
        try container.encode(valence, forKey: .valence)
        try container.encode(activation, forKey: .activation)
        try container.encode(dominance, forKey: .dominance)
        try container.encode(audioLevel ?? 0.0, forKey: .audioLevel)
    }
}


// MARK: - Calendar Data Model

struct CalendarData: Identifiable, Encodable {
    var id = UUID()
    let eventTitle: String
    let startDate: Int64
    let endDate: Int64
}
