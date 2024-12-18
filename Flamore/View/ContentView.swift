import SwiftUI

struct ContentView: View {
    @StateObject private var userData = UserData()
    
    var body: some View {
        if userData.isLoggedIn {
            HomeView()
                .environmentObject(userData)
        } else {
            AuthView()
                .environmentObject(userData)
        }
    }
}

#Preview {
    ContentView()
} 
