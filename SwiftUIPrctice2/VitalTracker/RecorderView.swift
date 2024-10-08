//
//  RecorderView.swift
//  VitalTracker
//
//  Created by SiJongKim on 10/7/24.
//

import SwiftUI

struct RecorderView: View {
    @ObservedObject var audioRecorderManager = AudioRecorderManager.shared
    @State private var showRecordedFiles = false
    @State private var recordingAnimation = false

    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            if audioRecorderManager.isRecording {
                Image(systemName: "waveform.path")
                    .font(.system(size: 100))
                    .foregroundColor(.blue)
                    .scaleEffect(recordingAnimation ? 1.5 : 1.0)
                    .animation(
                        recordingAnimation ?
                            .easeInOut(duration: 0.8)
                            .repeatForever(autoreverses: true) : .default,
                        value: recordingAnimation
                    )
                Text(" \(audioRecorderManager.formatTime(audioRecorderManager.recordingTime))")
                    .font(.title2)
                    .foregroundColor(.primary)
            } else {
                Text("🎙️ 음성 일기 기록하기")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            
            Spacer()
            
            HStack(spacing: 30) {
                Button(action: {
                    if self.audioRecorderManager.isRecording {
                        if audioRecorderManager.isPaused {
                            audioRecorderManager.resumeRecording()
                            audioRecorderManager.startTimer()
                            recordingAnimation = true
                        } else {
                            audioRecorderManager.pauseRecording()
                            audioRecorderManager.stopTimer()
                            recordingAnimation = false
                        }
                    } else {
                        self.audioRecorderManager.startRecording()
                        self.audioRecorderManager.startTimer()
                        recordingAnimation = true
                    }
                }, label: {
                    if audioRecorderManager.isRecording {
                        Image(systemName: audioRecorderManager.isPaused ? "play.fill" : "pause.fill")
                            .padding()
                            .background(audioRecorderManager.isPaused ? Color.orange : Color.red)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .font(.title)
                    } else {
                        Image(systemName: "recordingtape.circle")
                            .padding()
                            .foregroundColor(.green)
                            .font(.system(size: 80))
                    }
                })
                
                if audioRecorderManager.isRecording {
                    Button(action: {
                        self.audioRecorderManager.cancelRecording()
                        self.audioRecorderManager.resetTimer()
                    }, label: {
                        Image(systemName: "xmark.circle.fill")
                            .padding()
                            .background(Color.gray)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .font(.title2)
                    })
                }
            }
            
            HStack(alignment: .center, spacing: 30) {
                if audioRecorderManager.isPaused || !audioRecorderManager.isRecording {
                    Button(action: {
                        self.audioRecorderManager.saveRecording()
                        recordingAnimation = false
                    }, label: {
                        Text("녹음 저장하기")
                            .padding()
                            .background(Color.indigo)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    })
                }
                
                if !audioRecorderManager.isRecording {
                    Button(action: {
                        audioRecorderManager.loadRecordedFiles()
                        showRecordedFiles = true
                    }, label: {
                        Text("저장된 파일 보기")
                            .padding()
                            .background(Color.secondary)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    })
                    .sheet(isPresented: $showRecordedFiles, content: {
                        RecordedListView()
                    })
                }
            } // HStack
        }
        .padding()
    }
}

#Preview {
    RecorderView()
}
