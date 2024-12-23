//
//  InfoView.swift
//  Flamore
//
//  Created by Hoffer Andras on 2024. 12. 18..
//

import SwiftUI

struct InfoView: View {
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    @EnvironmentObject var userData: UserData
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var klubNev: String = "Castrum SC"
    @State private var klubCim: String = "1234 Budapest, Példa utca 123."
    @State private var klubTel: String = "+36 30 999 8888"
    @State private var edzoNev: String = "Pantelics Péter"
    @State private var isAnimating = false
    
    private func openMap() {
        let address = klubCim.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "maps://?address=\(address)") {
            UIApplication.shared.open(url)
        }
    }
    
    private func fetchKlubInfo() async {
        isLoading = true
        
        // Saját felhasználói adatok lekérdezése
        guard let url = URL(string: "\(Settings.baseURL)/api/felhasznalok/\(userData.id)") else {
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
            
            let decoder = JSONDecoder()
            let sajatAdat = try decoder.decode(UserDetails.self, from: data)
            
            // Az adatok beállítása a főszálon
            DispatchQueue.main.async {
                // Frissítjük a UserData objektumot
                userData.nev = sajatAdat.nev
                userData.email = sajatAdat.email
                userData.klub_id = sajatAdat.klub_id
                userData.edzo = sajatAdat.edzo
                userData.telefon = sajatAdat.telefon ?? ""
                userData.budopass = sajatAdat.budopass ?? ""
                userData.ovfokozat = sajatAdat.ovfokozat ?? ""
                userData.egyeb_adatok = sajatAdat.egyeb_adatok
                userData.profil_kep = sajatAdat.profil_kep
                isLoading = false
            }
            
        } catch {
            DispatchQueue.main.async {
                errorMessage = "Hiba történt az adatok betöltése közben: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
    
    private func fetchKlubDetails(klubId: Int) async {
        guard let url = URL(string: "\(Settings.baseURL)/api/klubok/\(klubId)") else {
            errorMessage = "Érvénytelen klub URL"
            isLoading = false
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                errorMessage = "Szerver hiba történt a klub adatok lekérdezésekor"
                isLoading = false
                return
            }
            
            let decoder = JSONDecoder()
            let klubInfo = try decoder.decode(KlubInfo.self, from: data)
            
            DispatchQueue.main.async {
                self.klubNev = klubInfo.nev
                self.klubCim = klubInfo.cim
                self.klubTel = klubInfo.telefon
                self.edzoNev = klubInfo.edzoNev
                self.isLoading = false
            }
            
        } catch {
            DispatchQueue.main.async {
                errorMessage = "Hiba történt a klub adatok betöltése közben: \(error.localizedDescription)"
                isLoading = false
            }
        }
    }
    
    var body: some View {
        ScrollView {
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            VStack(alignment: .leading, spacing: 24) {
                // Fejléc animált ikonnal
                HStack {
                    Text("Információk")
                        .font(.system(size: 34, weight: .bold))
                    
                    Spacer()
                    
                    if let profilKepUrl = userData.profil_kep,
                       let url = URL(string: profilKepUrl) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                            case .failure(_):
                                alapProfilKep
                            case .empty:
                                ProgressView()
                                    .frame(width: 40, height: 40)
                            @unknown default:
                                alapProfilKep
                            }
                        }
                    } else {
                        alapProfilKep
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 40)
                } else {
                    VStack(alignment: .leading, spacing: 20) {
                        // Személyes adatok - azonosító nélkül
                        InfoSection(
                            title: "Személyes adatok",
                            icon: "person.fill",
                            content: """
                            Név: \(userData.nev)
                            Email: \(userData.email)
                            Telefon: \(userData.telefon ?? "Nincs megadva")
                            \(userData.egyeb_adatok != nil ? "Egyéb: \(userData.egyeb_adatok!)" : "")
                            """
                        )
                        
                        // Sportolói adatok - regisztráció nélkül
                        InfoSection(
                            title: "Sportolói adatok",
                            icon: "figure.martial.arts",
                            content: """
                            Budopass: \(userData.budopass ?? "Nincs megadva")
                            Övfokozat: \(userData.ovfokozat ?? "Nincs megadva")
                            Edző: \(userData.edzo ? "Igen" : "Nem")
                            """
                        )
                        
                        // Klub információk - azonosító nélkül
                        InfoSection(
                            title: "Klub információk",
                            icon: "building.2.fill",
                            content: """
                            Klub neve: \(klubNev)
                            Vezető edző: \(edzoNev)
                            """,
                            buttons: [
                                InfoButton(
                                    icon: "map.fill",
                                    text: klubCim,
                                    action: openMap
                                ),
                                InfoButton(
                                    icon: "phone.fill",
                                    text: klubTel,
                                    action: {
                                        if let url = URL(string: "tel:\(klubTel.replacingOccurrences(of: " ", with: ""))") {
                                            UIApplication.shared.open(url)
                                        }
                                    }
                                )
                            ]
                        )
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Fejlesztői információk
                VStack(spacing: 8) {
                    Divider()
                        .padding(.horizontal)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Fejlesztő")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                            Text("Castrum Development Team")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        
                        Spacer()
                        
                        Text("v\(appVersion) (\(buildNumber))")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
                .background(Color(.systemBackground))
            }
        }
        .background(Color(.systemBackground))
        .onAppear {
            isAnimating = true
            Task {
                await fetchKlubInfo()
            }
        }
    }
}

struct InfoButton: View {
    let icon: String
    let text: String
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                Text(text)
                    .font(.system(size: 16))
            }
            .foregroundColor(.blue)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue.opacity(0.1))
                    .scaleEffect(isPressed ? 0.98 : 1.0)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .pressEvents(onPress: { isPressed = true },
                    onRelease: { isPressed = false })
    }
}

struct InfoSection: View {
    let title: String
    let icon: String
    let content: String
    var buttons: [InfoButton] = []
    @State private var isHovered = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
                    .scaleEffect(isHovered ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3), value: isHovered)
                
                Text(title)
                    .font(.system(size: 22, weight: .bold))
            }
            
            Text(content)
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .lineSpacing(8)
            
            if !buttons.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(buttons.indices, id: \.self) { index in
                        buttons[index]
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

// PressEvents modifier a gomb animációhoz
struct PressActions: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in onPress() }
                    .onEnded { _ in onRelease() }
            )
    }
}

extension View {
    func pressEvents(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        modifier(PressActions(onPress: onPress, onRelease: onRelease))
    }
}

// Hozd létre a megfelelő modellt a szerver válaszához
struct KlubInfo: Codable {
    let nev: String
    let cim: String
    let telefon: String
    let edzoNev: String
    // Add hozzá a többi szükséges mezőt
}

// Átnevezzük és egyszerűsítjük az alap profilképet
private var alapProfilKep: some View {
    Image(systemName: "person.circle.fill")
        .font(.system(size: 40))
        .foregroundColor(.blue)
        .frame(width: 40, height: 40)
}

#Preview {
    let testUserData = UserData()
    testUserData.nev = "Teszt Felhasználó"
    testUserData.email = "teszt@example.com"
    testUserData.klub_id = 1
    testUserData.edzo = true
    testUserData.id = 123
    testUserData.budopass = "BP123456"
    testUserData.ovfokozat = "2. dan"
    testUserData.telefon = "+36 30 123 4567"
    
    return InfoView()
        .environmentObject(testUserData)
}
