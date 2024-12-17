import SwiftUI

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var token: String?

    var body: some View {
        VStack {
            TextField("Felhasználónév", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            SecureField("Jelszó", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Bejelentkezés") {
                AuthService().login(username: username, password: password) { result in
                    switch result {
                    case .success(let jwt):
                        self.token = jwt
                        UserDefaults.standard.set(jwt, forKey: "jwtToken")
                    case .failure(let error):
                        print("Bejelentkezés sikertelen: \(error)")
                    }
                }
            }
            .padding()
        }
    }
}
