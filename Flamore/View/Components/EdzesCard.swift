import SwiftUI

struct EdzesCard: View {
    let edzes: Edzes
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(edzes.megnevezes)
                .font(.headline)
                .lineLimit(1)
            
            Text(formatDate(edzes.idopont))
                .font(.subheadline)
                .foregroundColor(.gray)
            
            HStack {
                Text("Terem: \(edzes.terem_id)")
                    .font(.caption)
                Spacer()
                if edzes.lezart {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 3)
    }
    
    private func formatDate(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        dateFormatter.locale = Locale(identifier: "hu_HU")
        
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "yyyy.MM.dd. HH:mm"
            return dateFormatter.string(from: date)
        }
        return dateString
    }
} 