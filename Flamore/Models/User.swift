import Foundation

class UserData: ObservableObject {
    @Published var id: Int = 0
    @Published var email: String = ""
    @Published var nev: String = ""
    @Published var klub_id: Int = 0
    @Published var edzo: Bool = false
    @Published var token: String = ""
    @Published var isLoggedIn: Bool = false
    @Published var telefon: String?
    @Published var budopass: String?
    @Published var ovfokozat: String?
    @Published var regisztracio_datum: String?
} 