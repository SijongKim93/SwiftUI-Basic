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
    var timeStamp: String
    var latitude: Float
    var longitude: Float
    var altitude: Float
}

// MARK: - Accelerometer Model
struct Accelerometer: Encodable, Identifiable {
    let id = UUID()
    var timeStamp: String
    var x: Float
    var y: Float
    var z: Float
    var magnitude: Float
    
    init(timeStamp: String, x: Float, y: Float, z: Float, magnitude: Float) {
        self.timeStamp = timeStamp
        self.x = x
        self.y = y
        self.z = z
        self.magnitude = sqrt(x * x + y * y + z * z)
    }
}

// MARK: - Pressure Data Model
struct PressureData: Encodable, Identifiable {
    let id = UUID()
    var timeStamp: String
    var pressure: Double
}

// MARK: - Battery Model
struct Battery: Encodable, Identifiable {
    let id = UUID()
    var timeStamp: String
    var level: Float
    var state: String
}

// MARK: - CallLog Model
struct CallLogDataPoint: Identifiable, Encodable {
    var id = UUID()
    let timestamp: Date
    let totalIncomingCalls: Int
    let totalOutgoingCalls: Int
    let totalCallDuration: TimeInterval
    let uniqueContacts: Int
}

// MARK: - AmbientLight Model
struct AmbientLightDataPoint: Identifiable, Encodable {
    var id = UUID()
    let timestamp: Date
    let lux: Float
    let placement: SRAmbientLightSample.SensorPlacement
    
    enum CodingKeys: String, CodingKey {
        case id, timestamp, lux, placement
    }
    
    func placementDescription() -> String {
        switch placement {
        case .unknown:
            return "알 수 없음"
        case .frontTop:
            return "Device 전면 상단"
        case .frontBottom:
            return "Device 전면 하단"
        case .frontRight:
            return "Device 전면 우측"
        case .frontLeft:
            return "Device 전면 죄측"
        case .frontTopRight:
            return "Device 전면 상단 우측"
        case .frontTopLeft:
            return "Device 전면 상단 좌측"
        case .frontBottomRight:
            return "Device 전면 하단 우측"
        case .frontBottomLeft:
            return "Device 전면 하단 좌측"
        @unknown default:
            return "알 수 없음"
        }
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(lux, forKey: .lux)
        try container.encode(placementDescription(), forKey: .placement)
    }
}

// MARK: - KeyboardLog Model
struct KeyboardMetricsDataPoint: Identifiable, Encodable {
    var id = UUID()
    let timestamp: Date
    let totalWords: Int
    let totalTaps: Int
    let totalDrags: Int
    let totalDeletions: Int
    let typingSpeed: Double
}

// MARK: - AppUsageLog Model
struct AppUsageDataPoint: Identifiable, Encodable {
    var id = UUID()
    let timestamp: Date
    let appName: String
    let usageDuration: TimeInterval
    let category: String
    let notificationCount: Int
    let webUsageDuration: TimeInterval
}

// MARK: - NotificationUsage Model
struct NotificationUsageDataPoint: Identifiable, Encodable {
    var id = UUID()
    let timestamp: Date
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
    let sessionIdentifier: String
    let sessionFlags: SRSpeechMetrics.SessionFlags
    let timestamp: Date
    let audioLevel: Double?
    let speechRecognitionResult: String?
    let speechExpression: String?
    
    enum CodingKeys: String, CodingKey {
        case id, sessionIdentifier, sessionFlags, timestamp, audioLevel, speechRecognitionResult, speechExpression
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(sessionIdentifier, forKey: .sessionIdentifier)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(audioLevel, forKey: .audioLevel)
        try container.encode(speechRecognitionResult, forKey: .speechRecognitionResult)
        try container.encode(speechExpression, forKey: .speechExpression)
        try container.encode("\(sessionFlags)", forKey: .sessionFlags)
    }
}
