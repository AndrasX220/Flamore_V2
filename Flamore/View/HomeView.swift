import SwiftUI

struct HomeView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Főoldal nézet
            EdzesekView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Főoldal")
                }
                .tag(0)
            
            // Hírek nézet
            HirekView()
                .tabItem {
                    Image(systemName: "newspaper.fill")
                    Text("Hírek")
                }
                .tag(1)
            
            // Előzmények nézet
            ElozményekView()
                .tabItem {
                    Image(systemName: "clock.fill")
                    Text("Előzmények")
                }
                .tag(2)
            
            // Adatok nézet
            AdatokView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Adatok")
                }
                .tag(3)
        }
    }
}

// Placeholder nézetek az egyes fülekhez
struct HirekView: View {
    var body: some View {
        NavigationView {
            Text("Hírek")
                .navigationTitle("Hírek")
        }
    }
}

struct ElozményekView: View {
    var body: some View {
        NavigationView {
            Text("Előzmények")
                .navigationTitle("Előzmények")
        }
    }
}

struct AdatokView: View {
    var body: some View {
        NavigationView {
            Text("Adatok")
                .navigationTitle("Adatok")
        }
    }
}

#Preview {
    HomeView()
} 