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
    
    func deleteAllIOSData() {
        let iosDataRef = realtimeDatabase.child("iOS")
        
        iosDataRef.observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists() else {
                print("삭제할 iOS 데이터가 없습니다.")
                return
            }
            
            let group = DispatchGroup()
            
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                group.enter()
                iosDataRef.child(child.key).removeValue { error, _ in
                    if let error = error {
                        print("iOS 데이터 삭제 실패: \(error.localizedDescription)")
                    } else {
                        print("iOS 데이터 삭제 성공: \(child.key)")
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                print("iOS 데이터 삭제 완료")
            }
        }
    }
    
    // MARK: - GPS Data to Firebase
    
    private func saveGpsDataToRealtimeDatabase(gpsData: Gps) {
        let gpsDataRef = realtimeDatabase.child("iOS").child(pinNumber).child(deviceModel).child("GpsData")
        
        gpsDataRef.queryOrdered(byChild: "timeStamp").queryEqual(toValue: gpsData.timeStamp).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                print("중복된 GPS 데이터가 이미 저장되어 있습니다.")
            } else {
                let newGpsDataRef = gpsDataRef.childByAutoId()
                let dataToUpload: [String: Any] = [
                    "timeStamp": gpsData.timeStamp,
                    "latitude": gpsData.latitude,
                    "longitude": gpsData.longitude,
                    "altitude": gpsData.altitude,
                    "speed": gpsData.speed,
                    "accuracy": gpsData.accuracy
                ]
                
                newGpsDataRef.setValue(dataToUpload) { error, _ in
                    if let error = error {
                        print("GPS 데이터 업로드 실패: \(error.localizedDescription)")
                    } else {
                        print("GPS 데이터 업로드 성공")
                    }
                }
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
        let gyroscopeDataRef = realtimeDatabase.child("iOS").child(pinNumber).child(deviceModel).child("GyroscopeData")
        
        gyroscopeDataRef.queryOrdered(byChild: "timeStamp").queryEqual(toValue: gyroscopeData.timestamp).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                print("중복된 Gyroscope 데이터가 이미 저장되어 있습니다.")
            } else {
                let newGyroscopeDataRef = gyroscopeDataRef.childByAutoId()
                let dataToUpload: [String: Any] = [
                    "timeStamp": gyroscopeData.timestamp,
                    "X": gyroscopeData.x,
                    "Y": gyroscopeData.y,
                    "Z": gyroscopeData.z
                ]
                
                newGyroscopeDataRef.setValue(dataToUpload) { error, _ in
                    if let error = error {
                        print("Gyroscope 데이터 업로드 실패: \(error.localizedDescription)")
                    } else {
                        print("Gyroscope 데이터 업로드 성공")
                    }
                }
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
        let magnetometerDataRef = realtimeDatabase.child("iOS").child(pinNumber).child(deviceModel).child("MagnetometerData")
        
        magnetometerDataRef.queryOrdered(byChild: "timeStamp").queryEqual(toValue: magnetometerData.timestamp).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                print("중복된 Magnetometer 데이터가 이미 저장되어 있습니다.")
            } else {
                let newMagnetometerDataRef = magnetometerDataRef.childByAutoId()
                let dataToUpload: [String: Any] = [
                    "timeStamp": magnetometerData.timestamp,
                    "X": magnetometerData.x,
                    "Y": magnetometerData.y,
                    "Z": magnetometerData.z
                ]
                
                newMagnetometerDataRef.setValue(dataToUpload) { error, _ in
                    if let error = error {
                        print("Magnetometer 데이터 업로드 실패: \(error.localizedDescription)")
                    } else {
                        print("Magnetometer 데이터 업로드 성공")
                    }
                }
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
        let accDataRef = realtimeDatabase.child("iOS").child(pinNumber).child(deviceModel).child("AccelermeterData")
        
        accDataRef.queryOrdered(byChild: "timeStamp").queryEqual(toValue: accelerData.timeStamp).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                print("중복된 Accelerometer 데이터가 이미 저장되어 있습니다.")
            } else {
                let newAccDataRef = accDataRef.childByAutoId()
                let dataToUpload: [String: Any] = [
                    "timeStamp": accelerData.timeStamp,
                    "x": accelerData.x,
                    "y": accelerData.y,
                    "z": accelerData.z
                ]
                
                newAccDataRef.setValue(dataToUpload) { error, _ in
                    if let error = error {
                        print("Acc 데이터 업로드 실패: \(error.localizedDescription)")
                    } else {
                        print("Acc 데이터 업로드 성공")
                    }
                }
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
        let pressureDataRef = realtimeDatabase.child("iOS").child(pinNumber).child(deviceModel).child("PressureData")
        
        pressureDataRef.queryOrdered(byChild: "timeStamp").queryEqual(toValue: pressureData.timeStamp).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                print("중복된 Pressure 데이터가 이미 저장되어 있습니다.")
            } else {
                let newPressureDataRef = pressureDataRef.childByAutoId()
                let dataToUpload: [String: Any] = [
                    "timeStamp": pressureData.timeStamp,
                    "pressure": pressureData.pressure
                ]
                
                newPressureDataRef.setValue(dataToUpload) { error, _ in
                    if let error = error {
                        print("Pressure 데이터 업로드 실패: \(error.localizedDescription)")
                    } else {
                        print("Pressure 데이터 업로드 성공")
                    }
                }
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
        let batteryDataRef = realtimeDatabase.child("iOS").child(pinNumber).child(deviceModel).child("BatteryData")
        
        batteryDataRef.queryOrdered(byChild: "timeStamp").queryEqual(toValue: batteryData.timeStamp).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                print("중복된 Battery 데이터가 이미 저장되어 있습니다.")
            } else {
                let newBatteryDataRef = batteryDataRef.childByAutoId()
                let dataToUpload: [String: Any] = [
                    "timeStamp": batteryData.timeStamp,
                    "batteryLevel": batteryData.level,
                    "batteryState": batteryData.state
                ]
                
                newBatteryDataRef.setValue(dataToUpload) { error, _ in
                    if let error = error {
                        print("Battery 데이터 업로드 실패: \(error.localizedDescription)")
                    } else {
                        print("Battery 데이터 업로드 성공")
                    }
                }
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
        let callLogDataRef = realtimeDatabase.child("iOS").child(pinNumber).child(deviceModel).child("CallLogData")
        
        callLogDataRef.queryOrdered(byChild: "timestamp").queryEqual(toValue: callLogData.timestamp).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                print("중복된 CallLog 데이터가 이미 저장되어 있습니다.")
            } else {
                let newCallLogDataRef = callLogDataRef.childByAutoId()
                let dataToUpload: [String: Any] = [
                    "timestamp": callLogData.timestamp,
                    "totalIncomingCalls": callLogData.totalIncomingCalls,
                    "totalOutgoingCalls": callLogData.totalOutgoingCalls,
                    "totalCallDuration": callLogData.totalCallDuration,
                    "uniqueContacts": callLogData.uniqueContacts
                ]
                
                newCallLogDataRef.setValue(dataToUpload) { error, _ in
                    if let error = error {
                        print("CallLog 데이터 업로드 실패: \(error.localizedDescription)")
                    } else {
                        print("CallLog 데이터 업로드 성공")
                    }
                }
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
        let ambientLightDataRef = realtimeDatabase.child("iOS").child(pinNumber).child(deviceModel).child("AmbientLightData")
        
        ambientLightDataRef.queryOrdered(byChild: "timestamp").queryEqual(toValue: ambientLightData.timestamp).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                print("중복된 AmbientLight 데이터가 이미 저장되어 있습니다.")
            } else {
                let newAmbientLightDataRef = ambientLightDataRef.childByAutoId()
                let dataToUpload: [String: Any] = [
                    "timestamp": ambientLightData.timestamp,
                    "lux": ambientLightData.lux
                ]
                
                newAmbientLightDataRef.setValue(dataToUpload) { error, _ in
                    if let error = error {
                        print("AmbientLight 데이터 업로드 실패: \(error.localizedDescription)")
                    } else {
                        print("AmbientLight 데이터 업로드 성공")
                    }
                }
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
        let keyboardDataRef = realtimeDatabase.child("iOS").child(pinNumber).child(deviceModel).child("KeyboardMetricsData")
        
        keyboardDataRef.queryOrdered(byChild: "timestamp").queryEqual(toValue: keyboardData.timestamp).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                print("중복된 KeyboardMetrics 데이터가 이미 저장되어 있습니다.")
            } else {
                let newKeyboardDataRef = keyboardDataRef.childByAutoId()
                let dataToUpload: [String: Any] = [
                    "timestamp": keyboardData.timestamp,
                    "totalWords": keyboardData.totalWords,
                    "totalTaps": keyboardData.totalTaps,
                    "totalDrags": keyboardData.totalDrags,
                    "totalDeletions": keyboardData.totalDeletions,
                    "typingSpeed": keyboardData.typingSpeed
                ]
                
                newKeyboardDataRef.setValue(dataToUpload) { error, _ in
                    if let error = error {
                        print("KeyboardMetrics 데이터 업로드 실패: \(error.localizedDescription)")
                    } else {
                        print("KeyboardMetrics 데이터 업로드 성공")
                    }
                }
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
        let appUsageDataRef = realtimeDatabase.child("iOS").child(pinNumber).child(deviceModel).child("AppUsageData")
        
        appUsageDataRef.queryOrdered(byChild: "timestamp").queryEqual(toValue: appUsageData.timestamp).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                print("중복된 AppUsage 데이터가 이미 저장되어 있습니다.")
            } else {
                let newAppUsageDataRef = appUsageDataRef.childByAutoId()
                let dataToUpload: [String: Any] = [
                    "timestamp": appUsageData.timestamp,
                    "appName": appUsageData.appName,
                    "usageDuration": appUsageData.usageDuration,
                    "category": appUsageData.category,
                    "notificationCount": appUsageData.notificationCount,
                    "webUsageDuration": appUsageData.webUsageDuration
                ]
                
                newAppUsageDataRef.setValue(dataToUpload) { error, _ in
                    if let error = error {
                        print("AppUsage 데이터 업로드 실패: \(error.localizedDescription)")
                    } else {
                        print("AppUsage 데이터 업로드 성공")
                    }
                }
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
        let deviceUsageDataRef = realtimeDatabase.child("iOS").child(pinNumber).child(deviceModel).child("DeviceUsageData")
        
        deviceUsageDataRef.queryOrdered(byChild: "timeStamp").queryEqual(toValue: deviceUsageData.timestamp).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                print("중복된 DeviceUsage 데이터가 이미 저장되어 있습니다.")
            } else {
                let newDeviceUsageDataRef = deviceUsageDataRef.childByAutoId()
                let dataToUpload: [String: Any] = [
                    "timeStamp": deviceUsageData.timestamp,
                    "screenWake": deviceUsageData.screenWakes,
                    "unlock": deviceUsageData.unlocks,
                    "unlockDuration": deviceUsageData.unlockDuration
                ]
                
                newDeviceUsageDataRef.setValue(dataToUpload) { error, _ in
                    if let error = error {
                        print("Device 데이터 업로드 실패: \(error.localizedDescription)")
                    } else {
                        print("Device 데이터 업로드 성공")
                    }
                }
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
        let notificationDataRef = realtimeDatabase.child("iOS").child(pinNumber).child(deviceModel).child("NotificationUsageData")
        
        notificationDataRef.queryOrdered(byChild: "timestamp").queryEqual(toValue: notificationData.timestamp).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                print("중복된 NotificationUsage 데이터가 이미 저장되어 있습니다.")
            } else {
                let newNotificationDataRef = notificationDataRef.childByAutoId()
                let dataToUpload: [String: Any] = [
                    "timestamp": notificationData.timestamp,
                    "appName": notificationData.appName,
                    "eventDescription": notificationData.eventDescription()
                ]
                
                newNotificationDataRef.setValue(dataToUpload) { error, _ in
                    if let error = error {
                        print("NotificationUsage 데이터 업로드 실패: \(error.localizedDescription)")
                    } else {
                        print("NotificationUsage 데이터 업로드 성공")
                    }
                }
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
        let speechDataRef = realtimeDatabase.child("iOS").child(pinNumber).child(deviceModel).child("TelephonySpeechMetricsData")
        
        speechDataRef.queryOrdered(byChild: "timestamp").queryEqual(toValue: speechData.timestamp).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                print("중복된 TelephonySpeechMetrics 데이터가 이미 저장되어 있습니다.")
            } else {
                let newSpeechDataRef = speechDataRef.childByAutoId()
                let dataToUpload: [String: Any] = [
                    "timestamp": speechData.timestamp,
                    "confidence": speechData.confidence,
                    "mood": speechData.mood,
                    "valence": speechData.valence,
                    "activation": speechData.activation,
                    "dominance": speechData.dominance,
                    "audioLevel": speechData.audioLevel ?? ""
                ]
                
                newSpeechDataRef.setValue(dataToUpload) { error, _ in
                    if let error = error {
                        print("TelephonySpeechMetrics 데이터 업로드 실패: \(error.localizedDescription)")
                    } else {
                        print("TelephonySpeechMetrics 데이터 업로드 성공")
                    }
                }
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
        let healthDataRef = realtimeDatabase.child("iOS").child(pinNumber).child(deviceModel).child("HealthData").child(category)
        
        healthDataRef.queryOrdered(byChild: "startDate").queryEqual(toValue: healthData.startDate).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                print("중복된 \(category) 데이터가 이미 저장되어 있습니다.")
            } else {
                let newHealthDataRef = healthDataRef.childByAutoId()
                
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
                
                newHealthDataRef.setValue(dataToUpload) { error, _ in
                    if let error = error {
                        print("\(category) 데이터 업로드 실패: \(error.localizedDescription)")
                    } else {
                        print("\(category) 데이터 업로드 성공")
                    }
                }
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
        let activityRef = realtimeDatabase.child("iOS").child(pinNumber).child(deviceModel).child("ActivityData")
        
        activityRef.queryOrdered(byChild: "timestamp").queryEqual(toValue: ActivityData.timeStamp).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                print("중복된 Activity 데이터가 이미 저장되어 있습니다.")
            } else {
                let newActivityRef = activityRef.childByAutoId()
                let dataToUpload: [String: Any] = [
                    "activityType": ActivityData.activityType,
                    "totalDistance": ActivityData.totalDistance,
                    "todayDistance": ActivityData.todayDistance,
                    "pace": ActivityData.pace,
                    "averageSpeed": ActivityData.averageSpeed,
                    "timestamp": ActivityData.timeStamp
                ]
                
                newActivityRef.setValue(dataToUpload) { error, _ in
                    if let error = error {
                        print("Activity 데이터 업로드 실패: \(error.localizedDescription)")
                    } else {
                        print("Activity 데이터 업로드 성공")
                    }
                }
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
