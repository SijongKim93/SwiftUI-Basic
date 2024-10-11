//
//  Sensor.swift
//  VitalTracker
//
//  Created by Jade Yoo on 2023/07/10.
//

import Foundation
import SensorKit

// MARK: - Gps Model
/// 시간, 좌표 (위도, 경도)
struct Gps: Encodable {
    var timeStamp: String
    var latitude: Float
    var longitude: Float
    var altitude: Float
}

// MARK: - GPS: Codable
struct GPSValue: Codable {
    let data: GPSData
}

struct GPSData: Codable {
    let latitude, longitude: String
}

typealias GpsDict = [String: GPSValue]

// MARK: - Accelerometer Model
/// 시간, x, y, z 축 가속도
struct Accelerometer: Encodable {
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

// MARK: - Accelerometer: Codable
struct AccValue: Codable {
    let data: AccData
}

struct AccData: Codable {
    let x, y, z, magnitude: String
}

typealias AccDict = [String: AccValue]

// MARK: - Pressure Data Model

struct PressureData {
    let timeStamp: String
    let pressure: Double
}

// MARK: - Battery Model
/// 시간, 배터리 레벨, 상태
struct Battery: Encodable {
    var timeStamp: String
    var level: Float
    var state: String
}

// MARK: - PowerState: Codable
struct PowerValue: Codable {
    let data: PowerData
}

struct PowerData: Codable {
    let level: String
    let state: String
}

typealias PowerStateDict = [String: PowerValue]

// MARK: - CallLog

struct CallLogDataPoint: Identifiable {
    var id = UUID()
    let timestamp: Date
    let totalIncomingCalls: Int
    let totalOutgoingCalls: Int
    let totalCallDuration: TimeInterval
    let uniqueContacts: Int
}

// MARK: - AmbientLight

struct AmbientLightDataPoint: Identifiable {
    var id = UUID()
    let timestamp: Date
    let lux: Float
    let placement: SRAmbientLightSample.SensorPlacement
    
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
}

// MARK: - KeyboardLog

struct KeyboardMetricsDataPoint: Identifiable {
    var id = UUID()
    let timestamp: Date
    let totalWords: Int
    let totalTaps: Int
    let totalDrags: Int
    let totalDeletions: Int
    let typingSpeed: Double
}

// MARK: - AppUsageLog

struct AppUsageDataPoint: Identifiable {
    var id = UUID()
    let timestamp: Date
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

struct DeviceUsageSummary: Identifiable {
    var id = UUID()
    let timestamp: Date
    let screenWakes: Int
    let unlocks: Int
    let unlockDuration: TimeInterval
}

// MARK: - NotificationUsage

struct NotificationUsageDataPoint: Identifiable {
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


// MARK: - TelephonySpeechMetrics

struct TelephonySpeechMetricsDataPoint: Identifiable {
    var id = UUID()
    let sessionIdentifier: String
    let sessionFlags: SRSpeechMetrics.SessionFlags
    let timestamp: Date
    let audioLevel: Double?   // 오디오 레벨 (Optional, Loudness)
    let speechRecognitionResult: String?  // 음성 인식 결과 (Optional)
    let speechExpression: String?  // 음성 표현 (Optional)
}
