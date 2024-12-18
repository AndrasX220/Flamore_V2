import SwiftUI

struct UserResponse: Codable {
    let token: String
    let user: UserDetails
}

struct UserDetails: Codable {
    let id: Int
    let nev: String
    let email: String
    let klub_id: Int
    let edzo: Bool
}

struct LoginView: View {
    @StateObject private var userData = UserData()
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(5.0)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            
            SecureField("Jelszó", text: $password)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(5.0)
            
            Button(action: loginUser) {
                Text("Bejelentkezés")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(5.0)
            }
            .padding()

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding()
        .fullScreenCover(isPresented: $userData.isLoggedIn) {
            HomeView()
                .environmentObject(userData)
        }
    }

    func loginUser() {
        guard let url = URL(string: "http://192.168.0.178:3000/api/auth/login") else {
            errorMessage = "Hibás URL."
            return
        }
        
        let body: [String: Any] = ["email": email, "jelszo": password]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    errorMessage = "Hálózati hiba: \(error.localizedDescription)"
                    return
                }

                if let data = data {
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("Szerver válasz: \(responseString)")
                    }
                    
                    do {
                        let userResponse = try JSONDecoder().decode(UserResponse.self, from: data)
                        userData.token = userResponse.token
                        userData.id = userResponse.user.id
                        userData.nev = userResponse.user.nev
                        userData.email = userResponse.user.email
                        userData.klub_id = userResponse.user.klub_id
                        userData.edzo = userResponse.user.edzo
                        userData.isLoggedIn = true
                        errorMessage = ""
                    } catch {
                        errorMessage = "Bejelentkezés sikertelen: \(error.localizedDescription)"
                        print("JSON parse hiba részletek: \(error)")
                    }
                } else {
                    errorMessage = "Bejelentkezés sikertelen: Nincs adat."
                }
            }
        }.resume()
    }
}
