//
//  CalendarView.swift
//  VitalTracker
//
//  Created by SiJongKim on 11/12/24.
//

import SwiftUI

struct CalendarView: View {
    @State private var selectedDate = Date()
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            monthView
            dayView
            
        }
    }
    
    private var monthView: some View {
        HStack(spacing: 30) {
            Button(
                action: {
                    changeMonth(-1)
                }, label: {
                    Image(systemName: "chevron.left")
                        .padding()
                }
            )
            
            Text(monthTitle(from: selectedDate))
                .font(.title)
            
            Button(
                action: {
                    changeMonth(1)
                }, label: {
                    Image(systemName: "chevron.right")
                        .padding()
                }
            )
        }
    }
    
    @ViewBuilder
    private var dayView: some View {
        let startDate = calendar.date(from: Calendar.current.dateComponents([.year, .month], from: selectedDate))!
        
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                let components = (
                    0..<calendar.range(of: .day, in: .month, for: startDate)!.count)
                    .map {
                        calendar.date(byAdding: .day, value: $0, to: startDate)!
                    }
                ForEach(components, id: \.self) { date in
                    VStack {
                        Text(day(from: date))
                            .font(.caption)
                        Text("\(calendar.component(.day, from: date))")
                            .font(.subheadline)
                        
                        CircularProgressView(progress: 0.75)
                            .frame(width: 20, height: 20)
                    }
                    .frame(width: 30, height: 60)
                    .padding(5)
                    .background(calendar.isDate(selectedDate, equalTo: date, toGranularity: .day) ? Color.green : Color.clear)
                    .cornerRadius(16)
                    .foregroundColor(calendar.isDate(selectedDate, equalTo: date, toGranularity: .day) ? .white : .black)
                    .onTapGesture {
                        selectedDate = date
                    }
                }
            }
        }
    }
    
//    private var blurView: some View {
//        HStack {
//            LinearGradient(
//                gradient: Gradient(
//                    colors: [
//                        Color.white.opacity(1),
//                        Color.white.opacity(0)
//                    ]
//                ),
//                startPoint: .leading,
//                endPoint: .trailing
//            )
//            .frame(width: 20)
//            .edgesIgnoringSafeArea(.leading)
//
//            Spacer()
//
//            LinearGradient(
//                gradient: Gradient(
//                    colors: [
//                        Color.white.opacity(1),
//                        Color.white.opacity(0)
//                    ]
//                ),
//                startPoint: .trailing,
//                endPoint: .leading
//            )
//            .frame(width: 20)
//            .edgesIgnoringSafeArea(.leading)
//        }
//    }
}

extension CalendarView {
    func monthTitle(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("MMMM yyyy")
        return dateFormatter.string(from: date)
    }
    
    func changeMonth(_ value: Int) {
        guard let date = calendar.date(
            byAdding: .month,
            value: value,
            to: selectedDate
        ) else {
            return
        }
        
        selectedDate = date
    }
    
    func day(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("E")
        return dateFormatter.string(from: date)
    }
}

#Preview {
    CalendarView()
}
