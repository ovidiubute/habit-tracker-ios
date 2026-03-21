import Foundation
import UIKit
import Combine

class DateStorageManager: ObservableObject {
    static let shared = DateStorageManager()
    private let userDefaults = UserDefaults.standard
    private let greenDatesKey = "greenDates"
    private let orangeDatesKey = "orangeDates"
    private let redDatesKey = "redDates"
    private let installDateKey = "installDate"
    
    @Published var greenDates: Set<String> = []
    @Published var orangeDates: Set<String> = []
    @Published var redDates: Set<String> = []
    @Published var currentDate = Date()
    
    private init() {
        loadData()
        setInstallDateIfNeeded()
        setupDayChangeNotifications()
        refreshCurrentDate() // Check once on init
    }
    
    private func setupDayChangeNotifications() {
        // Listen for day change notifications (iOS sends this automatically at midnight)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(dayChanged),
            name: .NSCalendarDayChanged,
            object: nil
        )
        
        // Listen for when app becomes active (covers app launch, coming from background, etc.)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appBecameActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    @objc private func dayChanged() {
        DispatchQueue.main.async {
            self.refreshCurrentDate()
        }
    }
    
    @objc private func appBecameActive() {
        DispatchQueue.main.async {
            self.refreshCurrentDate()
        }
    }
    
    private func refreshCurrentDate() {
        let newDate = Date()
        if !Calendar.current.isDate(currentDate, inSameDayAs: newDate) {
            currentDate = newDate
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setInstallDateIfNeeded() {
        if userDefaults.object(forKey: installDateKey) == nil {
            // Set install date to start of today to make logic cleaner
            let calendar = Calendar.current
            let startOfToday = calendar.startOfDay(for: Date())
            userDefaults.set(startOfToday, forKey: installDateKey)
        }
    }
    
    var installDate: Date {
        return userDefaults.object(forKey: installDateKey) as? Date ?? Date()
    }
    
    private func loadData() {
        if let greenDatesArray = userDefaults.array(forKey: greenDatesKey) as? [String] {
            greenDates = Set(greenDatesArray)
        }
        if let orangeDatesArray = userDefaults.array(forKey: orangeDatesKey) as? [String] {
            orangeDates = Set(orangeDatesArray)
        }
        if let redDatesArray = userDefaults.array(forKey: redDatesKey) as? [String] {
            redDates = Set(redDatesArray)
        }
    }
    
    private func saveData() {
        userDefaults.set(Array(greenDates), forKey: greenDatesKey)
        userDefaults.set(Array(orangeDates), forKey: orangeDatesKey)
        userDefaults.set(Array(redDates), forKey: redDatesKey)
    }
    
    func toggleDateColor(for date: Date) {
        let dateString = dateFormatter.string(from: date)
        
        if greenDates.contains(dateString) {
            // Green -> Orange
            greenDates.remove(dateString)
            orangeDates.insert(dateString)
        } else if orangeDates.contains(dateString) {
            // Orange -> Red
            orangeDates.remove(dateString)
            redDates.insert(dateString)
        } else if redDates.contains(dateString) {
            // Red -> Green
            redDates.remove(dateString)
            greenDates.insert(dateString)
        } else {
            // First time touching this date, make it green
            greenDates.insert(dateString)
        }
        
        saveData()
    }
    
    func getColorForDate(_ date: Date) -> DateColor {
        let dateString = dateFormatter.string(from: date)
        
        if greenDates.contains(dateString) {
            return .green
        } else if orangeDates.contains(dateString) {
            return .orange
        } else if redDates.contains(dateString) {
            return .red
        } else if dateString == dateFormatter.string(from: currentDate) {
            return .blue
        }
        return .gray // Default to gray for untouched dates
    }
    
    // Check if a date is available for interaction
    func canInteractWithDate(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Can't interact with future dates (but CAN interact with today and all past dates)
        return date <= today
    }
    
    // Get all dates that have been explicitly marked (for score calculation)
    var totalMarkedDays: Int {
        return greenDates.count + orangeDates.count + redDates.count
    }
    
    // Get count of green days
    var greenDaysCount: Int {
        return greenDates.count
    }
    
    // Get count of orange days
    var orangeDaysCount: Int {
        return orangeDates.count
    }
    
    // Get count of red days
    var redDaysCount: Int {
        return redDates.count
    }
    
    // Get total days that have become available for marking
    var totalAvailableDays: Int {
        let calendar = Calendar.current
        
        // Find the earliest date ever marked
        let allMarkedDatesStrings = greenDates.union(orangeDates).union(redDates)
        let allMarkedDates = allMarkedDatesStrings.compactMap { dateFormatter.date(from: $0) }
        let earliestMarked = allMarkedDates.min() ?? installDate
        
        // The start date is either the install date or the earliest marked date, whichever is earlier
        let startDate = calendar.startOfDay(for: min(installDate, earliestMarked))
        let endDate = calendar.startOfDay(for: currentDate)
        
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        
        if (components.day == nil) {
            return 1
        } else {
            // Include current day
            return components.day! + 1
        }
    }
    
    // Generate CSV data for export
    func generateCSVData() -> String {
        var csvString = "Date,Status\n"
        
        let allDates = (greenDates.map { ($0, "Success") } + 
                        orangeDates.map { ($0, "Cheat Day") } + 
                        redDates.map { ($0, "Failure") })
            .sorted { $0.0 < $1.0 }
        
        for (date, status) in allDates {
            csvString += "\(date),\(status)\n"
        }
        
        return csvString
    }
    
    // Debug function to print current state
    func printDebugInfo() {
        print("=== DEBUG INFO ===")
        print("Install Date: \(installDate)")
        print("Green Dates: \(greenDates)")
        print("Orange Dates: \(orangeDates)")
        print("Red Dates: \(redDates)")
        print("Total Available Days: \(totalAvailableDays)")
        print("Total Marked Days: \(totalMarkedDays)")
        print("Green Count: \(greenDaysCount)")
        print("Orange Count: \(orangeDaysCount)")
        print("Red Count: \(redDaysCount)")
        print("==================")
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

enum DateColor {
    case green, orange, red, gray, blue
}
