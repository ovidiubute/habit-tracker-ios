import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationView {
                CalendarView()
            }
            .tabItem {
                Image(systemName: "calendar")
                Text("Calendar")
            }
            
            NavigationView {
                ScoreView()
            }
            .tabItem {
                Image(systemName: "chart.bar.fill")
                Text("Score")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
