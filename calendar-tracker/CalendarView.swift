import SwiftUI

struct CalendarView: View {
    @StateObject private var storageManager = DateStorageManager.shared
    @State private var currentDate = Date()
    
    private let calendar = Calendar.current
    private let dateFormatter = DateFormatter()
    
    var body: some View {
        VStack(spacing: 30) {
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
            ZStack {
                // Main circle background
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 40, height: 40)
                
                // Today indicator ring
                if isToday {
                    Circle()
                        .stroke(todayRingColor, lineWidth: 3)
                        .frame(width: 44, height: 44)
                }
                
                // Date text
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 16, weight: isToday ? .bold : .medium))
                    .foregroundColor(textColor)
            }
        }
        .disabled(!canInteract)
        .scaleEffect(isToday ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isToday)
    }
    
    private var isToday: Bool {
        return calendar.isDate(date, inSameDayAs: Date())
    }
    
    private var canInteract: Bool {
        return storageManager.canInteractWithDate(date) || isToday
    }
    
    private var backgroundColor: Color {
        if isToday {
            // Today's date has special styling
            switch storageManager.getColorForDate(date) {
            case .green:
                return Color.green
            case .red:
                return Color.red
            case .gray:
                return Color.blue.opacity(0.8) // Special blue for today when unmarked
            }
        } else if !canInteract {
            return Color.gray.opacity(0.3)
        } else {
            // Past dates available for interaction
            switch storageManager.getColorForDate(date) {
            case .green:
                return Color.green
            case .red:
                return Color.red
            case .gray:
                return Color.gray.opacity(0.6) // Available but not yet marked
            }
        }
    }
    
    private var textColor: Color {
        if isToday {
            return Color.white
        }
        
        switch storageManager.getColorForDate(date) {
        case .green, .red:
            return Color.white
        case .gray:
            return canInteract ? Color.white : Color.gray
        }
    }
    
    private var todayRingColor: Color {
        switch storageManager.getColorForDate(date) {
        case .green:
            return Color.green.opacity(0.7)
        case .red:
            return Color.red.opacity(0.7)
        case .gray:
            return Color.blue
        }
    }
}

#Preview {
    NavigationView {
        CalendarView()
    }
}
