import SwiftUI

struct ScoreView: View {
    @StateObject private var storageManager = DateStorageManager.shared
    
    var body: some View {
        ScrollView {
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
                        Label("\(orangeDays)", systemImage: "minus.circle.fill")
                            .foregroundColor(.orange)
                        Spacer()
                        Text("Cheat Days")
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
                
                // Export Section
                VStack(spacing: 12) {
                    Divider()
                        .padding(.vertical, 8)
                    
                    Button(action: {
                        exportCSV()
                    }) {
                        Label("Export History (CSV)", systemImage: "square.and.arrow.up")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    
                    Text("Keep a safe copy of your progress.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Explanation text
                if totalMarkedDays == 0 {
                    Text("Start marking your days in the calendar to see your score!")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    Text("Score is calculated as (Green + Cheat Days) / Total Marked Days. Unmarked days don't count against you.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
            .padding()
        }
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
    
    private var orangeDays: Int {
        return storageManager.orangeDates.count
    }
    
    private var redDays: Int {
        return storageManager.redDates.count
    }
    
    private var scorePercentage: Int {
        guard totalMarkedDays > 0 else { return 0 }
        let successfulDays = Double(greenDays + orangeDays)
        let percentage = successfulDays / Double(totalMarkedDays) * 100
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
    
    private func exportCSV() {
        // Move heavy work to background thread to prevent UI lag
        DispatchQueue.global(qos: .userInitiated).async {
            let csvString = storageManager.generateCSVData()
            let fileName = "HabitTrackerBackup.csv"
            let path = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
            
            do {
                try csvString.write(to: path, atomically: true, encoding: .utf8)
                
                // Present UIActivityViewController on main thread
                DispatchQueue.main.async {
                    let av = UIActivityViewController(activityItems: [path], applicationActivities: nil)
                    
                    // For iPad compatibility
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let rootViewController = windowScene.windows.first?.rootViewController {
                        av.popoverPresentationController?.sourceView = rootViewController.view
                        rootViewController.present(av, animated: true, completion: nil)
                    }
                }
            } catch {
                print("Failed to create CSV file: \(error)")
            }
        }
    }
}

// A SwiftUI preview.
#Preview {
    ScoreView()
}
