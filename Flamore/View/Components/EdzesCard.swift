import SwiftUI

struct EdzesCard: View {
    let edzes: Edzes
    @State private var isRegistered = false
    @State private var showDetails = false
    
    private func formatDate(_ dateString: String) -> (date: String, time: String) {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        guard let date = inputFormatter.date(from: dateString) else {
            return (date: dateString, time: "")
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "hu_HU")
        
        dateFormatter.dateFormat = "MMM d."
        let formattedDate = dateFormatter.string(from: date)
        
        dateFormatter.dateFormat = "HH:mm"
        let formattedTime = dateFormatter.string(from: date)
        
        return (date: formattedDate.lowercased(), time: formattedTime)
    }
    
    var formattedDateTime: (date: String, time: String) {
        return formatDate(edzes.idopont)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Button(action: { 
                withAnimation(.spring()) {
                    showDetails.toggle()
                }
            }) {
                VStack(alignment: .leading, spacing: 16) {
                    // Fejléc
                    Text(edzes.megnevezes)
                        .font(.system(size: 18, weight: .bold))
                        .lineLimit(1)
                        .foregroundColor(.primary)
                    
                    // Terem
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.blue)
                        Text("Terem \(edzes.terem_id)")
                    }
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                    
                    // Dátum és időpont egymás mellett
                    HStack(spacing: 16) {
                        // Dátum
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.blue)
                            Text(formattedDateTime.date)
                                .fontWeight(.medium)
                        }
                        
                        // Időpont
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.blue)
                            Text(formattedDateTime.time)
                                .fontWeight(.medium)
                        }
                    }
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                }
            }
            
            // Jelentkezés gomb
            Button(action: { isRegistered.toggle() }) {
                HStack {
                    Image(systemName: isRegistered ? "checkmark.circle.fill" : "plus.circle.fill")
                    Text(isRegistered ? "Lemondás" : "Jelentkezés")
                }
                .font(.system(size: 16, weight: .medium))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(isRegistered ? Color.red.opacity(0.2) : Color.blue.opacity(0.2))
                )
                .foregroundColor(isRegistered ? .red : .blue)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
} 