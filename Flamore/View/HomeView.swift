import SwiftUI

struct HomeView: View {
    @EnvironmentObject var userData: UserData
    @State private var selectedTab = 0
    @State private var edzesek: [Edzes] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var selectedEdzesType: String?
    @State private var showAllWorkouts = false
    
    var edzesTypes: [String] {
        let types = Array(Set(edzesek.map { $0.megnevezes }))
        return types.sorted { a, b in
            let order = [
                "ovikarate",
                "gyerek karate",
                "haladó karate",
                "röplabda",
                "zsákedző",
                "zsákedző haladó"
            ]
            
            let aIndex = order.firstIndex { a.lowercased().contains($0) } ?? order.count
            let bIndex = order.firstIndex { b.lowercased().contains($0) } ?? order.count
            return aIndex < bIndex
        }
    }
    
    private func getEdzesIcon(for type: String) -> String {
        switch type.lowercased() {
        case let t where t.contains("gyerek karate"): return "🥋"
        case let t where t.contains("haladó karate"): return "🥋"
        case let t where t.contains("ovikarate"): return "🥋"
        case let t where t.contains("röplabda"): return "🏐"
        case let t where t.contains("zsákedző haladó"): return "🥊"
        case let t where t.contains("zsákedző"): return "🥊"
        default: return "💪"
        }
    }
    
    private func formatEdzesType(_ type: String) -> String {
        switch type.lowercased() {
        case let t where t.contains("gyerek karate"): return "Gyerek K."
        case let t where t.contains("haladó karate"): return "Haladó K."
        case let t where t.contains("ovikarate"): return "Ovi K."
        case let t where t.contains("röplabda"): return "Röpi"
        case let t where t.contains("zsákedző haladó"): return "Zsák H."
        case let t where t.contains("zsákedző"): return "Zsák"
        default: return type.components(separatedBy: " ").first ?? type
        }
    }
    
    var filteredEdzesek: [Edzes] {
        if let selectedType = selectedEdzesType {
            return edzesek.filter { $0.megnevezes == selectedType }
        }
        return edzesek
    }
    
    var displayedEdzesek: [Edzes] {
        if showAllWorkouts {
            return filteredEdzesek
        } else {
            return Array(filteredEdzesek.prefix(4))
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            mainView
                .tabItem {
                    Label(getTitle(for: 0), systemImage: getIcon(for: 0))
                }
                .tag(0)
            
            HirekView()
                .tabItem {
                    Label(getTitle(for: 1), systemImage: getIcon(for: 1))
                }
                .tag(1)
            
            Text("Előzmények")
                .tabItem {
                    Label(getTitle(for: 2), systemImage: getIcon(for: 2))
                }
                .tag(2)
            
            InfoView()
                .tabItem {
                    Label(getTitle(for: 3), systemImage: getIcon(for: 3))
                }
                .tag(3)
        }
        .tint(.blue)
    }
    
    private var mainView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profil fejléc
                HStack(spacing: 16) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.gray)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Castrum")
                            .foregroundColor(.gray)
                        Text(userData.nev)
                            .font(.title2)
                            .bold()
                    }
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                            .padding(8)
                            .background(Color.gray.opacity(0.2))
                            .clipShape(Circle())
                    }
                }
                .padding()
                
                // Figyelmeztető banner
                if !edzesek.isEmpty {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.white)
                        Text("1 kifizetetlen eseményed van")
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding()
                    .background(Color.red)
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                
                // Edzéstípus választó
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        Button(action: {
                            withAnimation {
                                selectedEdzesType = nil
                            }
                        }) {
                            HStack(spacing: 6) {
                                Text("🎯")
                                Text("Mind")
                            }
                            .foregroundColor(selectedEdzesType == nil ? .white : .primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(selectedEdzesType == nil ? Color.blue : Color.gray.opacity(0.2))
                            )
                        }
                        
                        ForEach(edzesTypes, id: \.self) { type in
                            Button(action: {
                                withAnimation {
                                    selectedEdzesType = type
                                }
                            }) {
                                HStack(spacing: 6) {
                                    Text(getEdzesIcon(for: type))
                                    Text(formatEdzesType(type))
                                }
                                .foregroundColor(selectedEdzesType == type ? .white : .primary)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(selectedEdzesType == type ? Color.blue : Color.gray.opacity(0.2))
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Edzések lista
                VStack(spacing: 16) {
                    ForEach(displayedEdzesek) { edzes in
                        EdzesCard(edzes: edzes)
                    }
                    
                    if filteredEdzesek.count > 4 {
                        Button(action: {
                            withAnimation {
                                showAllWorkouts.toggle()
                            }
                        }) {
                            HStack {
                                Text(showAllWorkouts ? "Bezárás" : "További edzések")
                                Image(systemName: showAllWorkouts ? "chevron.up" : "chevron.down")
                            }
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 49)
        }
        .background(Color(.systemBackground))
        .onAppear {
            fetchEdzesek()
        }
    }
    
    private func fetchEdzesek() {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "http://192.168.0.178:3000/api/edzesek") else {
            errorMessage = "Érvénytelen URL"
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    errorMessage = "Hiba történt: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    errorMessage = "Nem érkezett adat"
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    self.edzesek = try decoder.decode([Edzes].self, from: data)
                } catch {
                    errorMessage = "Hiba az adatok feldolgozása során: \(error.localizedDescription)"
                    print("Dekódolási hiba: \(error)")
                }
            }
        }.resume()
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

#Preview {
    let userData = UserData()
    userData.nev = "Bandesz"
    return HomeView().environmentObject(userData)
} 
