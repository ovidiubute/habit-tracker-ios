# Calendar Tracker - Project Analysis

## App Overview
**Calendar Tracker** is an iOS application built with SwiftUI that allows users to track their daily performance or habits using a simple color-coded calendar interface.

## Core Functionality
- **Daily Tracking**: Users can mark days as "Success" (Green), "Cheat Day" (Orange), or "Failure" (Red).
- **Calendar Interface**: A custom-built calendar grid with month-to-month navigation and swipe gestures.
- **Statistics**: A dedicated view showing the success rate (percentage) and counts of marked vs. unmarked days.
- **Persistence**: Data is persisted locally on the device.

## Technical Architecture

### UI Layer (SwiftUI)
- **`calendar_trackerApp`**: The main entry point.
- **`ContentView`**: Uses a `TabView` to switch between the Calendar and Statistics views.
- **`CalendarView`**: 
    - Manages the grid layout and navigation between months.
    - Uses nested `VStack/HStack` with stable index-based IDs for the 42-day grid to ensure layout stability during month transitions.
    - Implements swipe gestures for month navigation with light haptic feedback.
    - Features a clean, dynamic border on the "Today" marker for better visual identification.
    - The border color is dynamic: blue for unmarked, white for marked days to ensure visual harmony.
    - **Haptic Feedback**: Uses `UIImpactFeedbackGenerator` for satisfying physical interactions during marking and month navigation.
- **`ScoreView`**: 
    - Calculates and displays performance metrics.
    - Provides a visual breakdown of marked days (Green, Orange, Red).

### Data Management
- **`DateStorageManager`**: 
    - A singleton class (`ObservableObject`) that serves as the "Source of Truth".
    - Uses `UserDefaults` for persistent storage of green, orange, and red dates.
    - Handles date logic, such as determining if a date is interactable (preventing future marking).
    - Listens for `.NSCalendarDayChanged` and `UIApplication.didBecomeActiveNotification` to ensure the "today" marker stays current.

### Data Model
- **Dates**: Stored as a `Set<String>` in `yyyy-MM-dd` format.
- **Colors**: Defined by the `DateColor` enum (`green`, `orange`, `red`, `gray`, `blue`).
    - **Green**: Success.
    - **Orange**: "Cheat Day" (counts as success for stats).
    - **Red**: Failure.
    - **Blue**: Today (untouched).
    - **Gray**: Unmarked available date or future date.

## Development Constraints & Logic
- **Interactable Dates**: Users can mark any current or past dates. Future dates remain locked.
- **Historical Visibility**: Marked dates (Green, Orange, Red) retain their colors indefinitely. Unmarked historical dates are visually grayed out.
- **Toggle Cycle**: Tapping an available day cycles through: Green -> Orange -> Red -> Green.
- **Score Calculation**: `((Green Days + Orange Days) / Total Marked Days) * 100`. Unmarked days within the available range do not count towards the score.
- **Navigation**: Supports both button-based and gesture-based (swipe) month navigation.

## Project Versioning
- **Current Version**: 1.2.2
- **Current Build**: 2026.03.21.1

## File Structure
- `calendar_trackerApp.swift`: App lifecycle.
- `ContentView.swift`: Main tab navigation.
- `CalendarView.swift`: Calendar UI and logic.
- `ScoreView.swift`: Statistics and scoring logic.
- `DataStorageManager.swift`: Persistence and business logic.
