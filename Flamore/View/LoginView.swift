import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""
    @State private var isLoggedIn: Bool = false
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
        .fullScreenCover(isPresented: $isLoggedIn) {
            HomeView()
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

                if let httpResponse = response as? HTTPURLResponse {
                    print("HTTP válasz kód: \(httpResponse.statusCode)")
                }

                if let data = data {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                            if let token = json["token"] as? String {
                                isLoggedIn = true
                                errorMessage = ""
                            } else {
                                errorMessage = "Bejelentkezés sikertelen: Hibás token."
                            }
                        }
                    } catch {
                        errorMessage = "Bejelentkezés sikertelen: Érvénytelen válasz."
                    }
                } else {
                    errorMessage = "Bejelentkezés sikertelen: Nincs adat."
                }
            }
        }.resume()
    }
}
