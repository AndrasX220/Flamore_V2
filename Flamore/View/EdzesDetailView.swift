import SwiftUI
import EventKit

struct EdzesDetailView: View {
    let edzes: Edzes
    @Environment(\.dismiss) private var dismiss
    @State private var showingEventAlert = false
    @State private var eventAlertMessage = ""
    // Teszt adatok - később API-ból jön
    let jelentkezok = [
        "Nagy János", "Kiss Éva", "Szabó Péter", 
        "Kovács Anna", "Tóth Zoltán", "Varga Béla"
    ]
    // Teszt megjegyzés - később API-ból jön
    let megjegyzes = "Kérlek hozzatok magatokkal törölközőt és vizet. Az edzés intenzív lesz, kezdőknek is ajánlott, de saját tempóban lehet végezni a gyakorlatokat."
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Fejléc
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    
                    Spacer()
                    
                    Text("Edzés részletei")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Button(action: addToCalendar) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                .padding()
                
                // Edzés információk
                VStack(spacing: 20) {
                    Text(edzes.megnevezes)
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    // Időpont kártya
                    VStack(spacing: 8) {
                        HStack(spacing: 24) {
                            // Nap
                            VStack(spacing: 4) {
                                Image(systemName: "calendar")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                Text(formattedDay)
                                    .font(.title3)
                                    .fontWeight(.medium)
                            }
                            
                            // Óra
                            VStack(spacing: 4) {
                                Image(systemName: "clock")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                Text(formattedTime)
                                    .font(.title3)
                                    .fontWeight(.medium)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    HStack(spacing: 24) {
                        VStack {
                            Image(systemName: "person.2")
                                .font(.title2)
                                .foregroundColor(.blue)
                            Text("\(jelentkezok.count) fő")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        VStack {
                            Image(systemName: "building.2")
                                .font(.title2)
                                .foregroundColor(.blue)
                            Text("Terem \(edzes.terem_id)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        VStack {
                            Image(systemName: "stopwatch")
                                .font(.title2)
                                .foregroundColor(.blue)
                            Text("60 perc")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(16)
                .padding(.horizontal)
                
                // Edzői megjegyzés
                if !megjegyzes.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Edzői megjegyzés")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text(megjegyzes)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)
                }
                
                // Résztvevők
                VStack(alignment: .leading, spacing: 16) {
                    Text("Résztvevők (\(jelentkezok.count))")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(jelentkezok, id: \.self) { nev in
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(Color.blue.opacity(0.1))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Text(String(nev.prefix(1)))
                                            .foregroundColor(.blue)
                                            .font(.system(size: 16, weight: .medium))
                                    )
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(nev)
                                        .font(.system(size: 16, weight: .medium))
                                    Text("Tag")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                            }
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.bottom, 100)
        }
        .overlay(alignment: .bottom) {
            if !edzes.lezart {
                Button(action: {}) {
                    Text("Jelentkezés")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(16)
                }
                .padding()
                .background(
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .ignoresSafeArea()
                )
            }
        }
        .alert("Naptár", isPresented: $showingEventAlert) {
            Button("OK") {}
        } message: {
            Text(eventAlertMessage)
        }
    }
    
    private func addToCalendar() {
        let eventStore = EKEventStore()
        
        // Kérjünk engedélyt a naptár használatához
        eventStore.requestAccess(to: .event) { granted, error in
            DispatchQueue.main.async {
                if granted && error == nil {
                    // Dátum konvertálása
                    let components = edzes.idopont.split(separator: "T")
                    if components.count > 1 {
                        let dateStr = String(components[0])
                        let timeStr = String(components[1].split(separator: ".")[0])
                        let dateTimeStr = "\(dateStr)T\(timeStr)"
                        
                        let formatter = ISO8601DateFormatter()
                        formatter.formatOptions = [.withInternetDateTime]
                        
                        if let startDate = formatter.date(from: dateTimeStr) {
                            let event = EKEvent(eventStore: eventStore)
                            event.title = edzes.megnevezes
                            event.startDate = startDate
                            event.endDate = Calendar.current.date(byAdding: .hour, value: 1, to: startDate)
                            event.notes = megjegyzes
                            event.location = "Terem \(edzes.terem_id)"
                            event.calendar = eventStore.defaultCalendarForNewEvents
                            
                            do {
                                try eventStore.save(event, span: .thisEvent)
                                eventAlertMessage = "Az esemény sikeresen hozzáadva a naptárhoz!"
                            } catch {
                                eventAlertMessage = "Hiba történt az esemény mentésekor: \(error.localizedDescription)"
                            }
                        } else {
                            eventAlertMessage = "Nem sikerült feldolgozni az időpontot"
                        }
                    } else {
                        eventAlertMessage = "Érvénytelen időpont formátum"
                    }
                } else {
                    eventAlertMessage = "Nincs engedély a naptár használatához"
                }
                showingEventAlert = true
            }
        }
    }
    
    // Dátum formázók
    private var formattedDay: String {
        // Példa idopont formátum: "2024-06-01T08:00:00.000Z"
        let components = edzes.idopont.split(separator: "T")
        if components.count > 1 {
            let dateStr = String(components[0])
            let dateComponents = dateStr.split(separator: "-")
            
            if dateComponents.count == 3,
               let year = Int(dateComponents[0]),
               let month = Int(dateComponents[1]),
               let day = Int(dateComponents[2]) {
                
                let calendar = Calendar.current
                let date = calendar.date(from: DateComponents(year: year, month: month, day: day))
                
                let formatter = DateFormatter()
                formatter.dateFormat = "EEEE"  // Csak a nap neve
                formatter.locale = Locale(identifier: "hu_HU")
                
                if let date = date {
                    return formatter.string(from: date).capitalized
                }
            }
        }
        return "Nincs nap"
    }
    
    private var formattedTime: String {
        // Példa idopont formátum: "2024-06-01T08:00:00.000Z"
        let components = edzes.idopont.split(separator: "T")
        if components.count > 1 {
            let timeStr = String(components[1])
            let timeComponents = timeStr.split(separator: ":")
            
            if timeComponents.count > 1 {
                return "\(timeComponents[0]):\(timeComponents[1])"
            }
        }
        return "Nincs időpont"
    }
}

#Preview {
    EdzesDetailView(edzes: Edzes(
        id: 1,
        megnevezes: "Reggeli Jóga",
        idopont: "2024-06-01T08:00:00.000Z",
        terem_id: 3,
        klub_id: 2,
        lezart: false
    ))
} 