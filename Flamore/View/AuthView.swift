import SwiftUI

struct AuthView: View {
    @State private var isShowingLogin = true
    @State private var isAnimating = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // Modern animált háttér
            GeometryReader { geometry in
                ZStack {
                    // Első gradiens réteg
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.blue.opacity(0.3),
                            Color.purple.opacity(0.2)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .blur(radius: 30)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    
                    // Második gradiens réteg
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: geometry.size.width * 0.6)
                        .blur(radius: 20)
                        .offset(x: isAnimating ? 50 : -50, y: -100)
                    
                    // Harmadik gradiens réteg
                    Circle()
                        .fill(Color.purple.opacity(0.2))
                        .frame(width: geometry.size.width * 0.4)
                        .blur(radius: 20)
                        .offset(x: isAnimating ? -30 : 30, y: 100)
                }
                .animation(.easeInOut(duration: 5.0).repeatForever(autoreverses: true), value: isAnimating)
            }
            
            VStack(spacing: 24) {
                // Logo és címsor
                VStack(spacing: 16) {
                    Image(systemName: "flame.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.blue)
                        .background(
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                                .frame(width: 80, height: 80)
                        )
                        .scaleEffect(isAnimating ? 1.1 : 1.0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6).repeatForever(autoreverses: true), value: isAnimating)
                    
                    Text("Flamore")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primary)
                }
                .padding(.top, 60)
                
                // Váltó gombok
                HStack(spacing: 0) {
                    Button(action: {
                        withAnimation(.spring()) {
                            isShowingLogin = true
                        }
                    }) {
                        Text("Bejelentkezés")
                            .font(.system(size: 16, weight: .medium))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(isShowingLogin ? Color.blue : Color.clear)
                            )
                            .foregroundColor(isShowingLogin ? .white : .primary)
                    }
                    
                    Button(action: {
                        withAnimation(.spring()) {
                            isShowingLogin = false
                        }
                    }) {
                        Text("Regisztráció")
                            .font(.system(size: 16, weight: .medium))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(!isShowingLogin ? Color.blue : Color.clear)
                            )
                            .foregroundColor(!isShowingLogin ? .white : .primary)
                    }
                }
                .padding(4)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(.systemGray6))
                )
                .padding(.horizontal)
                
                // Login/Register form
                if isShowingLogin {
                    LoginView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .leading).combined(with: .opacity),
                            removal: .move(edge: .trailing).combined(with: .opacity)
                        ))
                } else {
                    RegisterView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                }
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    AuthView()
        .preferredColorScheme(.dark)
} 