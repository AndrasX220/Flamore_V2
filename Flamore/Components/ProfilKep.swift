import SwiftUI

struct ProfilKep: View {
    let url: String
    let size: CGFloat
    
    var body: some View {
        AsyncImage(url: URL(string: url)) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            case .failure(_):
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: size, height: size)
                    .overlay(
                        Text(String(url.prefix(1)))
                            .foregroundColor(.blue)
                            .font(.system(size: size * 0.4, weight: .medium))
                    )
            case .empty:
                ProgressView()
                    .frame(width: size, height: size)
            @unknown default:
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: size, height: size)
            }
        }
    }
} 