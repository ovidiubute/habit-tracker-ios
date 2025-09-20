import Foundation
import Combine

class DateStorageManager: ObservableObject {
    static let shared = DateStorageManager()
    private let userDefaults = UserDefaults.standard
    private let greenDatesKey = "greenDates"
    private let redDatesKey = "redDates"
    private let installDateKey = "installDate"
    
    @Published var greenDates: Set<String> = []
    @Published var redDates: Set<String> = []
    
    private init() {
        loadData()
        setInstallDateIfNeeded()
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
        if let redDatesArray = userDefaults.array(forKey: redDatesKey) as? [String] {
            redDates = Set(redDatesArray)
        }
    }
    
    private func saveData() {
        userDefaults.set(Array(greenDates), forKey: greenDatesKey)
        userDefaults.set(Array(redDates), forKey: redDatesKey)
    }
    
    func toggleDateColor(for date: Date) {
        let dateString = dateFormatter.string(from: date)
        
        if greenDates.contains(dateString) {
            // Green -> Red
            greenDates.remove(dateString)
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
        } else if redDates.contains(dateString) {
            return .red
        }
        return .gray // Default to gray for untouched dates
    }
    
    // Check if a date is available for interaction
    func canInteractWithDate(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let installDate = calendar.startOfDay(for: self.installDate)
        let dateToCheck = calendar.startOfDay(for: date)
        
        // Can't interact with future dates (including today)
        if dateToCheck > today {
            return false
        }
        
        // Can't interact with dates before install date
        if dateToCheck < installDate {
            return false
        }
        
        return true
    }
    
    // Get all dates that have been explicitly marked (for score calculation)
    var totalMarkedDays: Int {
        return greenDates.count + redDates.count
    }
    
    // Get count of green days
    var greenDaysCount: Int {
        return greenDates.count
    }
    
    // Get count of red days
    var redDaysCount: Int {
        return redDates.count
    }
    
    // Get total days that have become available for marking since install
    var totalAvailableDays: Int {
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: installDate)
        let endDate = calendar.startOfDay(for: Date())
        
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        return max(components.day ?? 0, 0)
    }
    
    // Debug function to print current state
    func printDebugInfo() {
        print("=== DEBUG INFO ===")
        print("Install Date: \(installDate)")
        print("Green Dates: \(greenDates)")
        print("Red Dates: \(redDates)")
        print("Total Available Days: \(totalAvailableDays)")
        print("Total Marked Days: \(totalMarkedDays)")
        print("Green Count: \(greenDaysCount)")
        print("Red Count: \(redDaysCount)")
        print("==================")
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
}

enum DateColor {
    case green, red, gray
}
