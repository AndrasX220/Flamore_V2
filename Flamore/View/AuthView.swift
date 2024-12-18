import SwiftUI

struct AuthView: View {
    @State private var isShowingLogin = true
    
    var body: some View {
        VStack {
            // Felső szegmens választó
            HStack {
                Button(action: { isShowingLogin = true }) {
                    Text("Bejelentkezés")
                        .foregroundColor(isShowingLogin ? .blue : .gray)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(
                            VStack {
                                Spacer()
                                Rectangle()
                                    .fill(isShowingLogin ? Color.blue : Color.clear)
                                    .frame(height: 2)
                            }
                        )
                }
                
                Button(action: { isShowingLogin = false }) {
                    Text("Regisztráció")
                        .foregroundColor(!isShowingLogin ? .blue : .gray)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(
                            VStack {
                                Spacer()
                                Rectangle()
                                    .fill(!isShowingLogin ? Color.blue : Color.clear)
                                    .frame(height: 2)
                            }
                        )
                }
            }
            .padding(.horizontal)
            
            // Nézet váltás
            if isShowingLogin {
                LoginView()
            } else {
                RegisterView()
            }
            
            Spacer()
        }
        .background(Color(.systemBackground))
    }
}

#Preview {
    AuthView()
        .environmentObject(UserData())
} 