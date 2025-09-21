# 📅 Habit Tracker – Simple iOS App (Swift)

A minimalist and intuitive **habit tracker** app built in **Swift** for iOS.  
Track your good and bad days at a glance using a simple color-coded calendar and stay motivated with a live success rate summary.

> ⚠️ This app is not published on the App Store. You can run it via Xcode on your own device.

---

## ✨ Features

- ✅ **Two-screen UI**:
  - **Calendar View**: Tap any date to mark it as a **good day (green)** or a **bad day (red)**.
  - **Score View**: See your overall performance as a **percentage of good days** since installing the app.
- 📅 **Interactive Calendar**: Tap on any day to toggle its state.
- 📊 **Live Score**: Tracks your progress and gives you a clear success percentage.
- 💾 **Local Storage**: All data is saved on-device and persists between launches.
- 🌙 **Dark Mode Support**

---

## 📸 Screenshots

| Calendar Screen | Stats Screen |
|-----------------|--------------|
| ![CalendarScreen](/screens/calendar.png?raw=true "Calendar Screen") | ![ScoreScreen](/screens/score.png?raw=true "Score Screen") |

---

## 🛠️ Installation

> Requires Xcode 15+ and iOS 17+ SDK.

1. Clone the repository:
   ```bash
   git clone https://github.com/ovidiubute/habit-tracker-ios.git
   cd habit-tracker-ios

2.	Open the project in Xcode:

    ```bash
    open HabitTracker.xcodeproj
    ```

3.	Build and run the app on a simulator or physical device.

⸻

📂 Project Structure

calendar-tracker/
├── CalendarView.swift        # Interactive calendar screen
├── ScoreView.swift           # Summary screen with good day % score
├── DataStorageManager.swift  # Business logic (device storage and compute score)

⸻

📦 Dependencies

No external dependencies – uses only native Swift and UIKit/SwiftUI.

⸻

🎬 Demo

Add a short video or animated GIF here showcasing the app in action.

⸻

📄 License

This project is licensed under the MIT License.

⸻

If you find this app useful, please ⭐ the repo and share it!
