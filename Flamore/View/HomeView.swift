import SwiftUI

struct HomeView: View {
    @EnvironmentObject var userData: UserData
    @State private var selectedTab = 0
    @State private var edzesek: [Edzes] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var selectedEdzesType: String?
    @State private var showAllWorkouts = false
    @State private var isRefreshing = false
    
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
        // Először konvertáljuk a dátumokat és rendezzük
        let sortedEdzesek = edzesek.sorted { edzes1, edzes2 in
            let date1 = isoDateFormatter.date(from: edzes1.idopont) ?? Date.distantFuture
            let date2 = isoDateFormatter.date(from: edzes2.idopont) ?? Date.distantFuture
            return date1 < date2
        }
        
        // Aztán szűrjük típus szerint, ha van kiválasztva
        if let selectedType = selectedEdzesType {
            return sortedEdzesek.filter { $0.megnevezes == selectedType }
        }
        return sortedEdzesek
    }
    
    // Dátum formázó a rendezéshez
    private let isoDateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    var displayedEdzesek: [Edzes] {
        if showAllWorkouts {
            return filteredEdzesek
        } else {
            return Array(filteredEdzesek.prefix(4))
        }
    }
    
    // Felhasználói adatok lekérdezése
    private func fetchUserData() async {
        guard let url = URL(string: "\(Settings.baseURL)/api/felhasznalok/\(userData.id)") else {
            errorMessage = "Érvénytelen URL"
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                errorMessage = "Szerver hiba történt"
                return
            }
            
            let decoder = JSONDecoder()
            let sajatAdat = try decoder.decode(UserDetails.self, from: data)
            
            DispatchQueue.main.async {
                userData.nev = sajatAdat.nev
                userData.email = sajatAdat.email
                userData.klub_id = sajatAdat.klub_id
                userData.edzo = sajatAdat.edzo
                userData.telefon = sajatAdat.telefon ?? ""
                userData.budopass = sajatAdat.budopass ?? ""
                userData.ovfokozat = sajatAdat.ovfokozat ?? ""
                userData.egyeb_adatok = sajatAdat.egyeb_adatok
                userData.profil_kep = sajatAdat.profil_kep
            }
            
        } catch {
            DispatchQueue.main.async {
                errorMessage = "Hiba történt az adatok betöltése közben: \(error.localizedDescription)"
            }
        }
    }
    
    // Minden adat frissítése
    private func refreshAll() async {
        isRefreshing = true
        // Párhuzamosan futtatjuk a lekérdezéseket
        async let userData = fetchUserData()
        async let edzesekData = fetchEdzesek()
        
        // Megvárjuk mindkét lekérdezés befejezését
        _ = await [userData, edzesekData]
        
        isRefreshing = false
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            mainView
                .tabItem {
                    Label(getTitle(for: 0), systemImage: getIcon(for: 0))
                }
                .tag(0)
                .task {
                    // Felhasználói adatok lekérdezése amikor a nézet megjelenik
                    await fetchUserData()
                }
            
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
                    if let profilKepUrl = userData.profil_kep,
                       let url = URL(string: profilKepUrl) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                            case .failure(_):
                                alapProfilKep
                            case .empty:
                                ProgressView()
                                    .frame(width: 50, height: 50)
                            @unknown default:
                                alapProfilKep
                            }
                        }
                    } else {
                        alapProfilKep
                    }
                    
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
        }
        .refreshable {
            await refreshAll()
        }
        .background(Color(.systemBackground))
        .onAppear {
            Task {
                await fetchEdzesek()
            }
        }
    }
    
    // Módosítjuk a fetchEdzesek függvényt, hogy async legyen
    private func fetchEdzesek() async {
        guard let url = URL(string: "\(Settings.baseURL)/api/edzesek") else {
            errorMessage = "Érvénytelen URL"
            isLoading = false
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                errorMessage = "Szerver hiba történt"
                isLoading = false
                return
            }
            
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
    
    private var alapProfilKep: some View {
        Image(systemName: "person.circle.fill")
            .resizable()
            .frame(width: 50, height: 50)
            .foregroundColor(.gray)
    }
}

#Preview {
    let userData = UserData()
    userData.nev = "Bandesz"
    return HomeView().environmentObject(userData)
} 
