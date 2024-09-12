//
//  EventKitManager.swift
//  SwiftUIBasic
//
//  Created by SiJongKim on 9/12/24.
//

import Foundation
import EventKit
import Combine

final class EventKitManager: ObservableObject {
    private let eventStore = EKEventStore()
    @Published var events: [EKEvent] = []
    @Published var authorizationStatus: EKAuthorizationStatus = .notDetermined
    
    init() {
        checkCalendarAuthorizationStatus()
    }
    
    func checkCalendarAuthorizationStatus() {
        authorizationStatus = EKEventStore.authorizationStatus(for: .event)
        
        switch authorizationStatus {
        case .notDetermined:
            requestAccessToCalendar()
        case .authorized:
            fetchEvents()
        case .denied, .restricted:
            print("캘린더 접근 권한이 거부되었습니다.")
        @unknown default:
            break
        }
    }
    
    func requestAccessToCalendar() {
        eventStore.requestAccess(to: .event) { [weak self] granted, error in
            if granted {
                DispatchQueue.main.async {
                    self?.fetchEvents()
                    self?.authorizationStatus = .authorized
                }
            } else {
                DispatchQueue.main.async {
                    self?.authorizationStatus = .denied
                }
            }
        }
    }
    
    func fetchEvents() {
        let startDate = Date()
        let endDate = Calendar.current.date(byAdding: .month, value: 1, to: startDate)!
        
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        let events = eventStore.events(matching: predicate)
        
        DispatchQueue.main.async {
            self.events = events
        }
    }
    
    func addEvent(title: String, startDate: Date, endDate: Date) {
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        do {
            try eventStore.save(event, span: .thisEvent)
            fetchEvents()
        } catch {
            print("이벤트 저장 중 오류")
        }
    }
}

