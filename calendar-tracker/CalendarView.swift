import SwiftUI

struct CalendarView: View {
    @StateObject private var storageManager = DateStorageManager.shared
    @State private var currentDate = Date()
    
    private let calendar = Calendar.current
    private let dateFormatter = DateFormatter()
    
    var body: some View {
        VStack {
            // Header with month/year
            HStack {
                Text(monthYearString)
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.horizontal)
            
            // Days of week header
            HStack {
                ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(calendarDays, id: \.self) { date in
                    if let date = date {
                        CalendarDayView(date: date, storageManager: storageManager)
                    } else {
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: 40)
                    }
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .navigationTitle("Calendar")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var monthYearString: String {
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: currentDate)
    }
    
    private var calendarDays: [Date?] {
        return generateCalendarDays()
    }
    
    private func generateCalendarDays() -> [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentDate) else {
            return []
        }
        
        let monthStart = monthInterval.start
        
        // Find the first day of the calendar grid (start of week containing first day of month)
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        let daysFromPreviousMonth = firstWeekday - 1
        
        guard let calendarStart = calendar.date(byAdding: .day, value: -daysFromPreviousMonth, to: monthStart) else {
            return []
        }
        
        var days: [Date?] = []
        var currentDay = calendarStart
        
        // Generate 42 days (6 weeks × 7 days) to fill the calendar grid
        for _ in 0..<42 {
            if calendar.isDate(currentDay, equalTo: currentDate, toGranularity: .month) {
                days.append(currentDay)
            } else {
                days.append(nil) // Days from previous/next month (empty cells)
            }
            
            // Move to next day
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDay) else {
                break
            }
            currentDay = nextDay
        }
        
        return days
    }
}

struct CalendarDayView: View {
    let date: Date
    @ObservedObject var storageManager: DateStorageManager
    
    private let calendar = Calendar.current
    
    var body: some View {
        Button(action: {
            if canInteract {
                storageManager.toggleDateColor(for: date)
            }
        }) {
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 16, weight: .medium))
                .frame(width: 40, height: 40)
                .background(backgroundColor)
                .foregroundColor(textColor)
                .clipShape(Circle())
        }
        .disabled(!canInteract)
    }
    
    private var canInteract: Bool {
        return storageManager.canInteractWithDate(date)
    }
    
    private var backgroundColor: Color {
        if !canInteract {
            return Color.gray.opacity(0.3)
        }
        
        switch storageManager.getColorForDate(date) {
        case .green:
            return Color.green
        case .red:
            return Color.red
        case .gray:
            return Color.gray.opacity(0.6) // Available but not yet marked
        }
    }
    
    private var textColor: Color {
        switch storageManager.getColorForDate(date) {
        case .green, .red:
            return Color.white
        case .gray:
            return canInteract ? Color.white : Color.gray
        }
    }
}

#Preview {
    NavigationView {
        CalendarView()
    }
}
