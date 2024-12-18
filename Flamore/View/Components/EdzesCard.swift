import SwiftUI

struct EdzesCard: View {
    let edzes: Edzes
    @State private var showingDetail = false
    // Teszt adatok a jelentkezőkhöz
    let jelentkezok = ["NJ", "KÉ", "SP", "KA", "TZ", "VB"]
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d."
        formatter.locale = Locale(identifier: "hu_HU")
        return formatter
    }
    
    private var isoFormatter: ISO8601DateFormatter {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }
    
    private var date: Date? {
        isoFormatter.date(from: edzes.idopont)
    }
    
    private var formattedTime: String {
        guard let date = date else { return "Nincs időpont" }
        return timeFormatter.string(from: date)
    }
    
    private var formattedDate: String {
        guard let date = date else { return "Nincs dátum" }
        return dateFormatter.string(from: date)
    }
    
    var body: some View {
        Button(action: { showingDetail = true }) {
            VStack(alignment: .leading, spacing: 12) {
                // Felső rész: Cím és státusz
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(edzes.megnevezes)
                            .font(.headline)
                            .lineLimit(2)
                        
                        HStack(spacing: 16) {
                            Label(formattedDate, systemImage: "calendar")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Label(formattedTime, systemImage: "clock")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                    
                    if edzes.lezart {
                        Text("Lezárva")
                            .font(.caption)
                            .padding(6)
                            .background(Color.red.opacity(0.1))
                            .foregroundColor(.red)
                            .cornerRadius(8)
                    }
                }
                
                // Középső rész: Terem információ és jelentkezők
                HStack {
                    Label("Terem \(edzes.terem_id)", systemImage: "building.2")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    // Átfedésben lévő profilképek
                    HStack(spacing: -10) {
                        ForEach(Array(jelentkezok.prefix(5).enumerated()), id: \.element) { index, monogram in
                            Circle()
                                .fill(Color.white)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle()
                                        .fill(Color.blue.opacity(0.1))
                                        .frame(width: 30, height: 30)
                                        .overlay(
                                            Text(monogram)
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(.blue)
                                        )
                                )
                        }
                        
                        if jelentkezok.count > 5 {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle()
                                        .fill(Color.blue.opacity(0.1))
                                        .frame(width: 30, height: 30)
                                        .overlay(
                                            Text("+\(jelentkezok.count - 5)")
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(.blue)
                                        )
                                )
                        }
                    }
                }
                
                Divider()
                
                // Alsó rész: Jelentkezés gomb
                if !edzes.lezart {
                    Button(action: {}) {
                        Text("Jelentkezés")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            .opacity(edzes.lezart ? 0.7 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingDetail) {
            EdzesDetailView(edzes: edzes)
        }
    }
}

#Preview {
    EdzesCard(edzes: Edzes(
        id: 1,
        megnevezes: "Reggeli Jóga",
        idopont: "2024-06-01T08:00:00.000Z",
        terem_id: 3,
        klub_id: 2,
        lezart: false
    ))
} 
