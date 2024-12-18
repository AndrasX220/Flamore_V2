import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Üdvözöllek az alkalmazásban!")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding()

                NavigationLink(destination: LoginView()) {
                    Text("Bejelentkezés")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)

                NavigationLink(destination: RegisterView()) {
                    Text("Regisztráció")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .navigationTitle("Főoldal")
        }
    }
}

#Preview {
    ContentView()
}
