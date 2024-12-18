import SwiftUI

struct LoginView: View {
    @EnvironmentObject var userData: UserData
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""
    
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
                    .background(Color.blue)
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
    }

    func loginUser() {
        guard let url = URL(string: "\(Settings.baseURL)/api/auth/login") else {
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

                guard let data = data else {
                    errorMessage = "Bejelentkezés sikertelen: Nincs adat."
                    return
                }
                
                do {
                    let loginResponse = try JSONDecoder().decode(LoginResponse.self, from: data)
                    // Frissítjük a UserData-t a login válasz alapján
                    userData.token = loginResponse.token
                    userData.id = loginResponse.user.id
                    userData.nev = loginResponse.user.nev
                    userData.email = loginResponse.user.email
                    userData.klub_id = loginResponse.user.klub_id
                    userData.edzo = loginResponse.user.edzo
                    userData.isLoggedIn = true
                    errorMessage = ""
                } catch {
                    errorMessage = "Bejelentkezés sikertelen: \(error.localizedDescription)"
                    print("JSON parse hiba részletek: \(error)")
                }
            }
        }.resume()
    }
}
