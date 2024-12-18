import Foundation

class UserData: ObservableObject {
    @Published var id: Int = 0
    @Published var nev: String = ""
    @Published var email: String = ""
    @Published var telefon: String = ""
    @Published var budopass: String = ""
    @Published var ovfokozat: String = ""
    @Published var egyeb_adatok: String?
    @Published var klub_id: Int = 0
    @Published var regisztracio_datum: String = ""
    @Published var edzo: Bool = false
    @Published var profil_kep: String?
    @Published var token: String = ""
    @Published var isLoggedIn: Bool = false
}

// Login API válasz dekódolásához
struct LoginUserDetails: Codable {
    let id: Int
    let nev: String
    let email: String
    let klub_id: Int
    let edzo: Bool
}

struct LoginResponse: Codable {
    let token: String
    let user: LoginUserDetails
}

// Teljes felhasználói adatok dekódolásához
struct UserDetails: Codable, Identifiable {
    let id: Int
    let nev: String
    let email: String
    let telefon: String?
    let budopass: String?
    let ovfokozat: String?
    let egyeb_adatok: String?
    let klub_id: Int
    let regisztracio_datum: String
    let edzo: Bool
    let profil_kep: String?
} 
