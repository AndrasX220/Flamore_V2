import SwiftUI

struct RegisterView: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""

    var body: some View {
        VStack {
            TextField("Név", text: $name)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(5.0)
            
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
            
            Button(action: registerUser) {
                Text("Regisztráció")
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
    func registerUser() {
        // Logoljuk a felhasználó által beírt adatokat (fejlesztési célra)
        print("Név: \(name)")
        print("Email: \(email)")
        print("Jelszó: \(password)")

        guard let url = URL(string: "http://192.168.0.178:3000/api/auth/register") else { return }
        
        let body: [String: Any] = ["nev": name, "email": email, "jelszo": password,"klub_id":1]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    errorMessage = "Hiba a szerverrel való kapcsolatban."
                }
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 {
                DispatchQueue.main.async {
                    errorMessage = "Sikeres regisztráció!"
                }
            } else {
                DispatchQueue.main.async {
                    errorMessage = "Regisztráció sikertelen."
                }
            }
        }.resume()
    }
}
