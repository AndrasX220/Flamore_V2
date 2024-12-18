import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var userData: UserData
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                TabView(selection: $selectedTab) {
                    HomeView()
                        .tag(0)
                    
                    HirekView()
                        .tag(1)
                    
                    ElozményekView()
                        .tag(2)
                    
                    InformaciokView()
                        .tag(3)
                }
                .edgesIgnoringSafeArea(.bottom)
                
                // Egyedi tab bar
                VStack(spacing: 0) {
                    Divider()
                    HStack(spacing: 0) {
                        ForEach(0..<4) { index in
                            Button(action: {
                                selectedTab = index
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: getIcon(for: index))
                                        .foregroundColor(selectedTab == index ? .blue : .gray)
                                    Text(getTitle(for: index))
                                        .font(.caption)
                                        .foregroundColor(selectedTab == index ? .blue : .gray)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    .padding(.top, 8)
                    .padding(.bottom, geometry.safeAreaInsets.bottom)
                    .background(
                        Color(.systemBackground)
                            .edgesIgnoringSafeArea(.bottom)
                            .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: -1)
                    )
                }
                .zIndex(2)
            }
        }
    }
    
    private func getIcon(for index: Int) -> String {
        switch index {
        case 0: return "house.fill"
        case 1: return "newspaper.fill"
        case 2: return "clock.fill"
        case 3: return "info.circle.fill"
        default: return ""
        }
    }
    
    private func getTitle(for index: Int) -> String {
        switch index {
        case 0: return "Főoldal"
        case 1: return "Hírek"
        case 2: return "Előzmények"
        case 3: return "Információk"
        default: return ""
        }
    }
}

struct HirekView: View {
    var body: some View {
        Text("Hírek")
    }
}

struct ElozményekView: View {
    var body: some View {
        Text("Előzmények")
    }
}

struct InformaciokView: View {
    var body: some View {
        Text("Információk")
    }
}

#Preview {
    MainTabView()
        .environmentObject(UserData())
} 