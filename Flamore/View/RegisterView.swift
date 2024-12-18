import SwiftUI

struct RegisterView: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""

    var body: some View {
        VStack(spacing: 16) {
            TextField("Név", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding(.horizontal)
            
            SecureField("Jelszó", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            Button(action: registerUser) {
                Text("Regisztráció")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding(.vertical)
    }

    func registerUser() {
        guard let url = URL(string: "\(Settings.baseURL)/api/auth/register") else { 
            errorMessage = "Érvénytelen URL"
            return 
        }
        
        let registerData = [
            "nev": name,
            "email": email,
            "jelszo": password,
            "klub_id": 1  // Alapértelmezett klub_id
        ] as [String: Any]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: registerData)
        } catch {
            errorMessage = "Hiba az adatok előkészítésénél"
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    errorMessage = "Hálózati hiba: \(error.localizedDescription)"
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    errorMessage = "Érvénytelen szerver válasz"
                    return
                }

                if httpResponse.statusCode == 201 {
                    errorMessage = "Sikeres regisztráció! Kérjük jelentkezzen be."
                } else {
                    if let data = data,
                       let errorResponse = String(data: data, encoding: .utf8) {
                        errorMessage = "Regisztráció sikertelen: \(errorResponse)"
                    } else {
                        errorMessage = "Regisztráció sikertelen: Hibakód \(httpResponse.statusCode)"
                    }
                }
            }
        }.resume()
    }
}
