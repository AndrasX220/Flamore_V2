import SwiftUI

struct HomeView: View {
    @EnvironmentObject var userData: UserData
    @State private var edzesek: [Edzes] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var selectedTerem: Int?
    @State private var showAllWorkouts = false
    
    var termek: [Int] {
        Array(Set(edzesek.map { $0.terem_id })).sorted()
    }
    
    var filteredEdzesek: [Edzes] {
        if let selectedTerem = selectedTerem {
            return edzesek.filter { $0.terem_id == selectedTerem }
        }
        return edzesek
    }
    
    var displayedEdzesek: [Edzes] {
        if showAllWorkouts {
            return filteredEdzesek
        } else {
            return Array(filteredEdzesek.prefix(4)) // Csak 4 edzés megjelenítése
        }
    }
    
    var body: some View {
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
                
                // Terem választó az API adatokból
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        Button(action: {
                            withAnimation {
                                selectedTerem = nil
                            }
                        }) {
                            Text("Összes")
                                .foregroundColor(selectedTerem == nil ? .white : .primary)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule()
                                        .fill(selectedTerem == nil ? Color.blue : Color.gray.opacity(0.2))
                                )
                        }
                        
                        ForEach(termek, id: \.self) { terem in
                            Button(action: {
                                withAnimation {
                                    selectedTerem = terem
                                }
                            }) {
                                Text("\(terem)")
                                    .foregroundColor(selectedTerem == terem ? .white : .primary)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(
                                        Capsule()
                                            .fill(selectedTerem == terem ? Color.blue : Color.gray.opacity(0.2))
                                    )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Edzések lista
                VStack(spacing: 16) {
                    ForEach(displayedEdzesek) { edzes in
                        EdzesListaItem(edzes: edzes)
                    }
                    
                    // További edzések / Bezárás gomb
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
}

struct EdzesListaItem: View {
    let edzes: Edzes
    @State private var isRegistered = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Edzés címe
            Text(edzes.megnevezes)
                .font(.title3)
                .bold()
            
            // Terem info
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                Text("Nagy terem")
                    .foregroundColor(.gray)
            }
            
            // Időpont
            HStack(spacing: 16) {
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.blue)
                    Text("jún. 1.")
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.blue)
                    Text("20:00")
                        .foregroundColor(.gray)
                }
            }
            
            // Résztvevők
            VStack(alignment: .leading, spacing: 8) {
                Text("Résztvevők")
                    .foregroundColor(.gray)
                
                HStack(spacing: 20) {
                    ForEach(["Kis Béla", "Nagy Ildikó", "Horváth Zsuzsa", "Szabó Bence"], id: \.self) { nev in
                        VStack {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.blue)
                            Text(nev)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            
            // Jelentkezés gomb
            Button(action: { isRegistered.toggle() }) {
                HStack {
                    Spacer()
                    Image(systemName: "plus")
                    Text("Jelentkezés")
                    Spacer()
                }
                .foregroundColor(.blue)
                .padding()
                .background(Color.blue.opacity(0.2))
                .cornerRadius(10)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(15)
    }
}

#Preview {
    let userData = UserData()
    userData.nev = "Teszt Felhasználó"
    return HomeView().environmentObject(userData)
} 