import SwiftUI

struct EdzesekView: View {
    @State private var edzesek: [Edzes] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Betöltés...")
            } else if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            } else {
                List(edzesek) { edzes in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(edzes.megnevezes)
                            .font(.headline)
                        
                        Text("Időpont: \(formatDate(edzes.idopont))")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        HStack {
                            Text("Terem: \(edzes.terem_id)")
                            Spacer()
                            if edzes.lezart {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Edzések")
        .onAppear {
            fetchEdzesek()
        }
    }
    
    private func fetchEdzesek() {
        guard let url = URL(string: "http://192.168.0.178:3000/api/edzesek") else {
            errorMessage = "Érvénytelen URL"
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    errorMessage = "Hiba történt: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    errorMessage = "Nem érkezett adat"
                    return
                }
                
                do {
                    let decodedEdzesek = try JSONDecoder().decode([Edzes].self, from: data)
                    self.edzesek = decodedEdzesek
                } catch {
                    errorMessage = "Hiba az adatok feldolgozása során: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    private func formatDate(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        if let date = dateFormatter.date(from: dateString) {
            dateFormatter.dateFormat = "yyyy.MM.dd HH:mm"
            return dateFormatter.string(from: date)
        }
        return dateString
    }
}

#Preview {
    NavigationView {
        EdzesekView()
    }
} 