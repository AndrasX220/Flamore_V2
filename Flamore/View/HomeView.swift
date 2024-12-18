import SwiftUI

struct HomeView: View {
    @EnvironmentObject var userData: UserData
    @State private var selectedTab = 0
    @State private var edzesek: [Edzes] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                // Főoldal nézet edzésekkel
                ScrollView {
                    if isLoading {
                        ProgressView("Edzések betöltése...")
                            .padding()
                    } else if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(edzesek) { edzes in
                                EdzesCard(edzes: edzes)
                            }
                        }
                        .padding()
                    }
                }
                .refreshable {
                    await fetchEdzesek()
                }
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Főoldal")
                }
                .tag(0)
                
                // Többi tab
                Text("Hírek")
                    .tabItem {
                        Image(systemName: "newspaper.fill")
                        Text("Hírek")
                    }
                    .tag(1)
                
                Text("Előzmények")
                    .tabItem {
                        Image(systemName: "clock.fill")
                        Text("Előzmények")
                    }
                    .tag(2)
                
                Text("Adatok")
                    .tabItem {
                        Image(systemName: "person.fill")
                        Text("Adatok")
                    }
                    .tag(3)
            }
            .navigationTitle("Üdv, \(userData.nev)!")
        }
        .onAppear {
            Task {
                await fetchEdzesek()
            }
        }
    }
    
    private func fetchEdzesek() async {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "http://192.168.0.178:3000/api/edzesek") else {
            errorMessage = "Érvénytelen URL"
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(userData.token)", forHTTPHeaderField: "Authorization")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decodedEdzesek = try JSONDecoder().decode([Edzes].self, from: data)
            
            DispatchQueue.main.async {
                self.edzesek = decodedEdzesek
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Hiba történt: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
}

#Preview {
    let userData = UserData()
    userData.nev = "Teszt Felhasználó"
    return HomeView().environmentObject(userData)
} 