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
    
    @Published var isRecording = false
    @Published var recordedFileURL: URL?
    @Published var recordedFiles: [URL] = []
    
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
            
            let fileName = UUID().uuidString + ".m4a"
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
            print("녹음 시작")
        } catch {
            print("녹음 오류 발생: \(error.localizedDescription)")
        }
    }
    
    func stopRecording() {
        audioRecorder?.stop()
        isRecording = false
        print("녹음 중지")
    }
    
    func cancelRecording() {
        audioRecorder?.stop()
        if let url = recordedFileURL {
            try? FileManager.default.removeItem(at: url)
        }
        isRecording = false
        recordedFileURL = nil
        print("녹음 취소 및 파일 삭제")
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
}

extension AudioRecorderManager: AVAudioRecorderDelegate {
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            print("녹음 실패")
            cancelRecording()
        }
    }
}
