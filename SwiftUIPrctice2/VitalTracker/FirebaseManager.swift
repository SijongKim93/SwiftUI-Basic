//
//  FirebaseManager.swift
//  VitalTracker
//
//  Created by SiJongKim on 10/15/24.
//

import FirebaseDatabase
import UIKit
import SwiftUI

final class FirebaseManager {
    
    static let shared = FirebaseManager()
    private let realtimeDatabase = Database.database().reference()
    private let deviceModel = UIDevice.current.model
    
    @AppStorage("PinNumber") private var pinNumber: String = "PinNumber"
    
    private var timer: Timer?
    
    private init() {
        startPeriodicDataUpload()
    }
    
    // MARK: - Send To Firebase
    
    func sendDataToFirebase() {
        sendGpsData()
        sendAccData()
        sendGyroscopeData()
        sendMagnetometerData()
        sendSpeechData()
        sendBatteryData()
        sendPressureData()
        sendCallLogData()
        sendAppUsageData()
        sendDeviceUsageData()
        sendAmbientLightData()
        sendKeyboardMetricsData()
        sendNotificationUsageData()
        sendHealthData()
        sendActivityData()
    }
    
    private func startPeriodicDataUpload() {
        timer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }
            self.sendDataToFirebase()
        })
    }
    
    // MARK: - Fetch last saved timestamp
    
    
    // MARK: - Delete Firebase Data
    
    func deleleAllData() {
        let iosRef = realtimeDatabase.child("iOS")
            
            iosRef.observeSingleEvent(of: .value) { snapshot in
                guard snapshot.exists() else {
                    print("iOS 경로에 데이터가 존재하지 않습니다.")
                    return
                }
                
                let group = DispatchGroup()
                
                for child in snapshot.children.allObjects as! [DataSnapshot] {
                    group.enter()
                    
                    iosRef.child(child.key).removeValue { error, _ in
                        if let error = error {
                            print("\(child.key) 데이터 삭제 실패: \(error.localizedDescription)")
                        } else {
                            print("\(child.key) 데이터 삭제 성공")
                        }
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    print("모든 iOS 데이터 삭제 완료")
                }
            }
    }
    
    // MARK: - GPS Data to Firebase
    
    private func saveGpsDataToRealtimeDatabase(gpsData: Gps) {
        let gpsDataRef = realtimeDatabase.child("iOS").child(pinNumber).child(deviceModel).child("GpsData").childByAutoId()
        let dataToUpload: [String: Any] = [
            "timeStamp": gpsData.timeStamp,
            "latitude": gpsData.latitude,
            "longitude": gpsData.longitude,
            "altitude": gpsData.altitude
        ]
        
        gpsDataRef.setValue(dataToUpload) { error, _ in
            if let error = error {
                print("GPS 데이터 업로드 실패: \(error.localizedDescription)")
            } else {
                print("GPS 데이터 업로드 성공")
            }
        }
    }
    
    private func sendGpsData() {
        let gpsDataList = LocationManager.shared.gpsDataList
        for gpsData in gpsDataList {
            saveGpsDataToRealtimeDatabase(gpsData: gpsData)
        }
    }
    
    // MARK: - Gyroscope Data to Firebase
    
    private func saveGyroscopeDataToRealtimeDatabase(gyroscopeData: GyroscopeData) {
        let gyroscopeDataRef = realtimeDatabase.child("iOS").child(pinNumber).child(deviceModel).child("GyroscopeData").childByAutoId()
        let dataToUpload: [String: Any] = [
            "timeStamp": gyroscopeData.timestamp,
            "X": gyroscopeData.x,
            "Y": gyroscopeData.y,
            "Z": gyroscopeData.z
        ]
        
        gyroscopeDataRef.setValue(dataToUpload) { error, _ in
            if let error = error {
                print("Gyroscope 데이터 업로드 실패: \(error.localizedDescription)")
            } else {
                print("Gyroscope 데이터 업로드 성공")
            }
        }
    }
    
    private func sendGyroscopeData() {
        let gyroscopeDataList = GyroscopeManager.shared.gyroDataList
        for gyroscopeData in gyroscopeDataList {
            saveGyroscopeDataToRealtimeDatabase(gyroscopeData: gyroscopeData)
        }
    }
    
    // MARK: - Magnetometer Data to Firebase
    
    private func saveMagnetometerDataToRealtimeDatabase(magnetometerData: MagnetometerData) {
        let magnetometerDataRef = realtimeDatabase.child("iOS").child(pinNumber).child(deviceModel).child("MagnetometerData").childByAutoId()
        let dataToUpload: [String: Any] = [
            "timeStamp": magnetometerData.timestamp,
            "X": magnetometerData.x,
            "Y": magnetometerData.y,
            "Z": magnetometerData.z
        ]
        
        magnetometerDataRef.setValue(dataToUpload) { error, _ in
            if let error = error {
                print("Magnetometer 데이터 업로두 실패: \(error.localizedDescription)")
            } else {
                print("Magnetometer 데이터 업로드 성공")
            }
        }
    }
    
    private func sendMagnetometerData() {
        let magnetometerDataList = MagnetometerManager.shared.magnetometerDataList
        for magnetometerData in magnetometerDataList {
            saveMagnetometerDataToRealtimeDatabase(magnetometerData: magnetometerData)
        }
    }
    
    // MARK: - Accelerometer Data to Firebase
    
    private func saveAccDataToRealtimeDatabase(accelerData: Accelerometer) {
        let accDataRef = realtimeDatabase.child("iOS").child(pinNumber).child(deviceModel).child("AccelermeterData").childByAutoId()
        let dataToUpload: [String: Any] = [
            "timeStamp": accelerData.timeStamp,
            "x": accelerData.x,
            "y": accelerData.y,
            "z": accelerData.z,
            "magnitude": accelerData.magnitude
        ]
        
        accDataRef.setValue(dataToUpload) { error, _ in
            if let error = error {
                print("Acc 데이터 업로드 실패: \(error.localizedDescription)")
            } else {
                print("Acc 데이터 업로드 성공")
            }
        }
    }
    
    private func sendAccData() {
        let accelerometerDataList = MotionManager.shared.accelerationDataList
        for accData in accelerometerDataList {
            saveAccDataToRealtimeDatabase(accelerData: accData)
        }
    }
    
    // MARK: - PressureData to Firebase
    
    private func savePressureDataToRealtimeDatabase(pressureData: PressureData) {
        let pressureDataRef = realtimeDatabase.child("iOS").child(pinNumber).child(deviceModel).child("PressureData").childByAutoId()
        let dataToUpload: [String: Any] = [
            "timeStamp": pressureData.timeStamp,
            "pressure": pressureData.pressure
        ]
        
        pressureDataRef.setValue(dataToUpload) { error, _ in
            if let error = error {
                print("Pressure 데이터 업로드 실패: \(error.localizedDescription)")
            } else {
                print("Pressure 데이터 업로드 성공")
            }
        }
    }
    
    private func sendPressureData() {
        let pressureDataList = MotionManager.shared.pressureDataList
        for pressureData in pressureDataList {
            savePressureDataToRealtimeDatabase(pressureData: pressureData)
        }
    }
    
    // MARK: - BatteryData to Firebase
    
    private func saveBatteryDataToRealtimeDatabase(batteryData: Battery) {
        let batteryDataRef = realtimeDatabase.child("iOS").child(pinNumber).child(deviceModel).child("BatteryData").childByAutoId()
        let dataToUpload: [String: Any] = [
            "timeStamp": batteryData.timeStamp,
            "batteryLevel": batteryData.level,
            "batteryState": batteryData.state
        ]
        
        batteryDataRef.setValue(dataToUpload) { error, _ in
            if let error = error {
                print("Battery 데이터 업로드 실패: \(error.localizedDescription)")
            } else {
                print("Battery 데이터 업로드 성공")
            }
        }
    }
    
    private func sendBatteryData() {
        let batteryDataList = BatteryManager.shared.batteryDataList
        for batteryData in batteryDataList {
            saveBatteryDataToRealtimeDatabase(batteryData: batteryData)
        }
    }
    
    // MARK: - CallLogData to Firebase
    
    private func saveCallLogDataToRealtimeDatabase(callLogData: CallLogDataPoint) {
        let callLogDataRef = realtimeDatabase.child("iOS").child(pinNumber).child(deviceModel).child("CallLogData").childByAutoId()
        let dataToUpload: [String: Any] = [
            "timestamp": callLogData.timestamp,
            "totalIncomingCalls": callLogData.totalIncomingCalls,
            "totalOutgoingCalls": callLogData.totalOutgoingCalls,
            "totalCallDuration": callLogData.totalCallDuration,
            "uniqueContacts": callLogData.uniqueContacts
        ]
        
        callLogDataRef.setValue(dataToUpload) { error, _ in
            if let error = error {
                print("CallLog 데이터 업로드 실패: \(error.localizedDescription)")
            } else {
                print("CallLog 데이터 업로드 성공")
            }
        }
    }
    
    private func sendCallLogData() {
        let callLogDataList = CallLogManager.shared.callLogData
        for callLogData in callLogDataList {
            saveCallLogDataToRealtimeDatabase(callLogData: callLogData)
        }
    }
    
    // MARK: - AmbientLightData to Firebase
    
    private func saveAmbientLightDataToRealtimeDatabase(ambientLightData: AmbientLightDataPoint) {
        let ambientLightDataRef = realtimeDatabase.child("iOS").child(pinNumber).child(deviceModel).child("AmbientLightData").childByAutoId()
        let dataToUpload: [String: Any] = [
            "timestamp": ambientLightData.timestamp,
            "lux": ambientLightData.lux
        ]
        
        ambientLightDataRef.setValue(dataToUpload) { error, _ in
            if let error = error {
                print("AmbientLight 데이터 업로드 실패: \(error.localizedDescription)")
            } else {
                print("AmbientLight 데이터 업로드 성공")
            }
        }
    }
    
    private func sendAmbientLightData() {
        let ambientLightDataList = AmbientManager.shared.ambientLightData
        for ambientLightData in ambientLightDataList {
            saveAmbientLightDataToRealtimeDatabase(ambientLightData: ambientLightData)
        }
    }
    
    
    // MARK: - KeyboardMetricsData to Firebase
    
    private func saveKeyboardMetricsDataToRealtimeDatabase(keyboardData: KeyboardMetricsDataPoint) {
        let keyboardDataRef = realtimeDatabase.child("iOS").child(pinNumber).child(deviceModel).child("KeyboardMetricsData").childByAutoId()
        let dataToUpload: [String: Any] = [
            "timestamp": keyboardData.timestamp,
            "totalWords": keyboardData.totalWords,
            "totalTaps": keyboardData.totalTaps,
            "totalDrags": keyboardData.totalDrags,
            "totalDeletions": keyboardData.totalDeletions,
            "typingSpeed": keyboardData.typingSpeed
        ]
        
        keyboardDataRef.setValue(dataToUpload) { error, _ in
            if let error = error {
                print("KeyboardMetrics 데이터 업로드 실패: \(error.localizedDescription)")
            } else {
                print("KeyboardMetrics 데이터 업로드 성공")
            }
        }
    }
    
    private func sendKeyboardMetricsData() {
        let keyboardMetricsDataList = KeyboardMetricsManager.shared.keyboardMetricsData
        for keyboardData in keyboardMetricsDataList {
            saveKeyboardMetricsDataToRealtimeDatabase(keyboardData: keyboardData)
        }
    }
    
    // MARK: - AppUsageData to Firebase
    
    private func saveAppUsageDataToRealtimeDatabase(appUsageData: AppUsageDataPoint) {
        let appUsageDataRef = realtimeDatabase.child("iOS").child(pinNumber).child(deviceModel).child("AppUsageData").childByAutoId()
        let dataToUpload: [String: Any] = [
            "timestamp": appUsageData.timestamp,
            "appName": appUsageData.appName,
            "usageDuration": appUsageData.usageDuration,
            "category": appUsageData.category,
            "notificationCount": appUsageData.notificationCount,
            "webUsageDuration": appUsageData.webUsageDuration
        ]
        
        appUsageDataRef.setValue(dataToUpload) { error, _ in
            if let error = error {
                print("AppUsage 데이터 업로드 실패: \(error.localizedDescription)")
            } else {
                print("AppUsage 데이터 업로드 성공")
            }
        }
    }
    
    private func sendAppUsageData() {
        let appUsageDataList = DeviceUsageManager.shared.appUsageData
        for appUsageData in appUsageDataList {
            saveAppUsageDataToRealtimeDatabase(appUsageData: appUsageData)
        }
    }
    
    // MARK: - DeviceUsageData to Firebase
    
    private func saveDeviceUsageDataToRealtimeDatabase(deviceUsageData: DeviceUsageSummary) {
        let deviceUsageDataRef = realtimeDatabase.child("iOS").child(pinNumber).child(deviceModel).child("DeviceUsageData").childByAutoId()
        let dataToUpload: [String: Any] = [
            "timeStamp": deviceUsageData.timestamp,
            "screenWake": deviceUsageData.screenWakes,
            "unlock": deviceUsageData.unlocks,
            "unlockDuration": deviceUsageData.unlockDuration
        ]
        
        deviceUsageDataRef.setValue(dataToUpload) { error, _ in
            if let error = error {
                print("Device 데이터 업로드 실패: \(error.localizedDescription)")
            } else {
                print("Device 데이터 업로드 성공")
            }
        }
    }
    
    private func sendDeviceUsageData() {
        let deviceUsageDataList = DeviceUsageManager.shared.deviceUsageSummary
        for deviceUsageData in deviceUsageDataList {
            saveDeviceUsageDataToRealtimeDatabase(deviceUsageData: deviceUsageData)
        }
    }
    
    // MARK: - NotificationUsageData to Firebase
    
    private func saveNotificationUsageDataToRealtimeDatabase(notificationData: NotificationUsageDataPoint) {
        let notificationDataRef = realtimeDatabase.child("iOS").child(pinNumber).child(deviceModel).child("NotificationUsageData").childByAutoId()
        let dataToUpload: [String: Any] = [
            "timestamp": notificationData.timestamp,
            "appName": notificationData.appName,
            "event": notificationData.event,
            "eventDescription": notificationData.eventDescription()
        ]
        
        notificationDataRef.setValue(dataToUpload) { error, _ in
            if let error = error {
                print("NotificationUsage 데이터 업로드 실패: \(error.localizedDescription)")
            } else {
                print("NotificationUsage 데이터 업로드 성공")
            }
        }
    }
    
    private func sendNotificationUsageData() {
        let notificationDataList = DeviceUsageManager.shared.notificationUsageData
        for notificationData in notificationDataList {
            saveNotificationUsageDataToRealtimeDatabase(notificationData: notificationData)
        }
    }
    
    // MARK: - TelephonySpeechMetricsData to Firebase
    
    private func saveTelephonySpeechMetricsDataToRealtimeDatabase(speechData: TelephonySpeechMetricsDataPoint) {
        let speechDataRef = realtimeDatabase.child("iOS").child(pinNumber).child(deviceModel).child("TelephonySpeechMetricsData").childByAutoId()
        let dataToUpload: [String: Any] = [
            "sessionIdentifier": speechData.sessionIdentifier,
            "sessionFlags": speechData.sessionFlagsDescription,
            "timestamp": speechData.timestamp,
            "audioLevel": speechData.audioLevel ?? NSNull(),
            "speechRecognitionResult": speechData.speechRecognitionResult ?? NSNull(),
            "speechExpression": speechData.speechExpressionDescription
        ]
        
        speechDataRef.setValue(dataToUpload) { error, _ in
            if let error = error {
                print("TelephonySpeechMetrics 데이터 업로드 실패: \(error.localizedDescription)")
            } else {
                print("TelephonySpeechMetrics 데이터 업로드 성공")
            }
        }
    }

    private func sendSpeechData() {
        let speechDataList = SpeechMetricsManager.shared.telephonySpeechMetricsData
        for speechData in speechDataList {
            saveTelephonySpeechMetricsDataToRealtimeDatabase(speechData: speechData)
        }
    }
    
    // MARK: - HealthKit Data to Firebase
    
    private func saveHealthDataToRealtimeDatabase(healthData: Record, category: String) {
        let healthDataRef = realtimeDatabase.child("iOS").child(pinNumber).child(deviceModel).child("HealthData").child(category).childByAutoId()
        
        var dataToUpload: [String: Any] = [
            "startDate": healthData.startDate,
            "endDate": healthData.endDate
        ]
        
        if category == "StepData", let stepCount = healthData.count {
            dataToUpload["stepCount"] = stepCount
        }
        
        if category == "BPMData", let BPM = healthData.beatsPerMinute {
            dataToUpload["BPM"] = BPM
        }
        
        if category == "SleepData", let sleepState = healthData.stage {
            dataToUpload["sleepState"] = sleepState
        }
        
        healthDataRef.setValue(dataToUpload) { error, _ in
            if let error = error {
                print("\(category) 데이터 업로드 실패: \(error.localizedDescription)")
            } else {
                print("\(category) 데이터 업로드 성공")
            }
        }
    }

    private func sendHealthData() {
        let stepRecords = HealthKitManager.shared.stepCountList
        let heartRateRecords = HealthKitManager.shared.heartRateList
        let sleepRecords = HealthKitManager.shared.sleepAnalysisList

        for stepData in stepRecords {
            saveHealthDataToRealtimeDatabase(healthData: stepData, category: "StepData")
        }
        
        for heartRateData in heartRateRecords {
            saveHealthDataToRealtimeDatabase(healthData: heartRateData, category: "BPMData")
        }
        
        for sleepData in sleepRecords {
            saveHealthDataToRealtimeDatabase(healthData: sleepData, category: "SleepData")
        }
    }
    
    // MARK: - Activity Data to Firebase
    
    private func saveActivityDataToRealtimeFirebase(ActivityData: Activity) {
        let activityRef = realtimeDatabase.child("iOS").child(pinNumber).child(deviceModel).child("ActivityData").childByAutoId()
        let dataToUpload: [String: Any] = [
            "activityType": ActivityData.activityType,
            "totalDistance": ActivityData.totalDistance,
            "todayDistance": ActivityData.todayDistance,
            "pace": ActivityData.pace,
            "averageSpeed": ActivityData.averageSpeed,
            "timestamp": ActivityData.timeStamp
        ]
        
        activityRef.setValue(dataToUpload) { error, _ in
            if let error = error {
                print("Activity 데이터 업로드 실패: \(error.localizedDescription)")
            } else {
                print("Activity 데이터 업로드 성공")
            }
        }
    }
    
    private func sendActivityData() {
        let activityList = ActivityManager.shared.activityData
        for activity in activityList {
            saveActivityDataToRealtimeFirebase(ActivityData: activity)
        }
    }
}
