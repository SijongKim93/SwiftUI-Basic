//
//  AudioRecorderManager.swift
//  VitalTracker
//
//  Created by SiJongKim on 10/7/24.
//

import Foundation
import AVFoundation
import Combine

class AudioRecorderManager: NSObject, ObservableObject {
    static let shared = AudioRecorderManager()
    
    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var timer: Timer?
    
    @Published var isRecording = false
    @Published var isPaused = false
    @Published var recordedFileURL: URL?
    @Published var recordedFiles: [URL] = []
    @Published var recordingTime: TimeInterval = 0
    
    private override init() {
        super.init()
        loadRecordedFiles()
    }
    
    private func requestPermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { allowed in
            if !allowed {
                print("마이크 사용 권한이 거부되었습니다.")
            }
        }
    }
    
    func startRecording() {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            
            let fileName = generateFileName() + ".m4a"
            let url = getDocumentsDirectory().appendingPathComponent(fileName)
            recordedFileURL = url
            
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.delegate = self
            audioRecorder?.record()
            
            isRecording = true
            isPaused = false
            print("녹음 시작")
        } catch {
            print("녹음 오류 발생: \(error.localizedDescription)")
        }
    }
    
    func pauseRecording() {
        if isRecording {
            audioRecorder?.pause()
            isPaused = true
            print("녹음 일시 중지")
        }
    }
    
    func resumeRecording() {
        if isPaused {
            audioRecorder?.record()
            isPaused = false
            print("녹음 재개")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        isPaused = false
        print("녹음 중지")
    }
    
    func cancelRecording() {
        audioRecorder?.stop()
        
        isRecording = false
        recordedFileURL = nil
        print("녹음 취소")
    }
    
    func saveRecording() {
        if let url = recordedFileURL {
            print("녹음 파일 저장 완료: \(url.lastPathComponent)")
            loadRecordedFiles()
        }
    }
    
    func deleteAllRecordings() {
        recordedFiles.forEach { fileURL in
            try? FileManager.default.removeItem(at: fileURL)
        }
        recordedFiles.removeAll()
        print("모든 녹음 파일 삭제")
    }
    
    func deleteRecording(at url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
            loadRecordedFiles()
        } catch {
            print("파일 삭제 실패: \(error.localizedDescription)")
        }
    }
    
    func playRecording(at url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            print("녹음 파일 재생 중: \(url.lastPathComponent)")
        } catch {
            print("오디오 재생 실패: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Timer 관리
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            self.recordingTime += 1
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func resetTimer() {
        recordingTime = 0
    }
    
    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func loadRecordedFiles() {
        let documentsURL = getDocumentsDirectory()
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            recordedFiles = fileURLs.filter { $0.pathExtension == "m4a" }
        } catch {
            print("녹음 파일 목록 로드 오류: \(error.localizedDescription)")
        }
    }
    
    private func generateFileName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return formatter.string(from: Date())
    }
}

extension AudioRecorderManager: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            print("녹음 실패")
            cancelRecording()
        }
    }
}
