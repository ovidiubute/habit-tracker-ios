import SwiftUI

struct ScoreView: View {
    @StateObject private var storageManager = DateStorageManager.shared
    
    var body: some View {
        VStack(spacing: 30) {
            // Score display
            VStack(spacing: 10) {
                Text("\(scorePercentage)%")
                    .font(.system(size: 72, weight: .bold))
                    .foregroundColor(scoreColor)
                
                Text("Success Rate")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
            
            // Statistics
            VStack(spacing: 16) {
                HStack {
                    Label("\(totalAvailableDays)", systemImage: "calendar")
                    Spacer()
                    Text("Days Available")
                }
                
                HStack {
                    Label("\(totalMarkedDays)", systemImage: "hand.tap.fill")
                    Spacer()
                    Text("Days Marked")
                }
                
                HStack {
                    Label("\(greenDays)", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Spacer()
                    Text("Green Days")
                }
                
                HStack {
                    Label("\(redDays)", systemImage: "xmark.circle.fill")
                        .foregroundColor(.red)
                    Spacer()
                    Text("Red Days")
                }
                
                if totalMarkedDays < totalAvailableDays {
                    HStack {
                        Label("\(totalAvailableDays - totalMarkedDays)", systemImage: "circle")
                            .foregroundColor(.gray)
                        Spacer()
                        Text("Unmarked Days")
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Explanation text
            if totalMarkedDays == 0 {
                Text("Start marking your days in the calendar to see your score!")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            } else if totalMarkedDays < totalAvailableDays {
                Text("Score is calculated only from days you've marked. Unmarked days don't count against you.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Statistics")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var totalAvailableDays: Int {
        return storageManager.totalAvailableDays
    }
    
    private var totalMarkedDays: Int {
        return storageManager.totalMarkedDays
    }
    
    private var greenDays: Int {
        return storageManager.greenDates.count
    }
    
    private var redDays: Int {
        return storageManager.redDates.count
    }
    
    private var scorePercentage: Int {
        guard totalMarkedDays > 0 else { return 0 }
        let percentage = Double(greenDays) / Double(totalMarkedDays) * 100
        return Int(ceil(percentage)) // Round up to nearest whole number
    }
    
    private var scoreColor: Color {
        guard totalMarkedDays > 0 else { return .gray }
        
        switch scorePercentage {
        case 80...100:
            return .green
        case 50..<80:
            return .orange
        default:
            return .red
        }
    }
}

// A SwiftUI preview.
#Preview {
    ScoreView()
}
