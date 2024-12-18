struct EdzesResztvevok: Codable {
    let resztvevok_szama: Int
    let resztvevok: [User]
}

struct User: Identifiable, Codable {
    let id: Int
    let nev: String
    let telefon: String
    let profil_kep: String
    let ottvolt: Bool
    let resztvetel_datum: String
} 