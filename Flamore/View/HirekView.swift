import SwiftUI

// Extension a dátum formázáshoz
extension String {
    func formatDateToSingleLine() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        if let date = dateFormatter.date(from: self) {
            dateFormatter.dateFormat = "MMMM d. HH:mm"
            dateFormatter.locale = Locale(identifier: "hu_HU")
            return dateFormatter.string(from: date)
        }
        return self
    }
}

struct HirekView: View {
    @State private var hirek: [Hir] = []
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var selectedHir: Hir?
    @State private var showingDetail = false
    @State private var showAllNews = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Hírek")
                    .font(.system(size: 34, weight: .bold))
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                if isLoading {
                    VStack {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 40)
                        Text("Hírek betöltése...")
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                    }
                } else if hirek.isEmpty {
                    Text("Nincsenek megjeleníthető hírek")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 40)
                } else {
                    ForEach(displayedHirek) { hir in
                        HirCard(hir: hir, selectedHir: $selectedHir, showingDetail: $showingDetail)
                            .padding(.horizontal)
                    }
                    
                    if !showAllNews && hirek.count > 4 {
                        Button(action: { showAllNews = true }) {
                            Text("Több hír mutatása")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                }
            }
        }
        .refreshable {
            await fetchHirek()
        }
        .sheet(item: $selectedHir) { hir in
            NavigationView {
                HirDetailView(hir: hir)
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                selectedHir = nil
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
            }
        }
        .task {
            if hirek.isEmpty {
                await fetchHirek()
            }
        }
    }
    
    // Rendezett hírek
    private var sortedHirek: [Hir] {
        hirek.sorted { hir1, hir2 in
            let date1 = isoDateFormatter.date(from: hir1.letrehozasDatum) ?? Date.distantPast
            let date2 = isoDateFormatter.date(from: hir2.letrehozasDatum) ?? Date.distantPast
            return date1 > date2  // Legújabb hírek elöl
        }
    }
    
    private var displayedHirek: [Hir] {
        if showAllNews {
            return sortedHirek
        } else {
            return Array(sortedHirek.prefix(4))
        }
    }
    
    private let isoDateFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    private func fetchHirek() async {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "\(Settings.baseURL)/api/hirek") else {
            errorMessage = "Érvénytelen URL"
            isLoading = false
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                errorMessage = "Szerver hiba történt"
                isLoading = false
                return
            }
            
            let decoder = JSONDecoder()
            let ujHirek = try decoder.decode([Hir].self, from: data)
            
            DispatchQueue.main.async {
                self.hirek = ujHirek
                self.isLoading = false
            }
            
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Hiba történt az adatok betöltése közben: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
}

struct HirDetailView: View {
    let hir: Hir
    @State private var showingFullScreenImage = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let kepUrl = hir.kep,
                   let url = URL(string: kepUrl) {
                    Button(action: {
                        showingFullScreenImage = true
                    }) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(maxHeight: 300)
                                    .clipped()
                            case .failure(_):
                                defaultSportImage
                            case .empty:
                                ProgressView()
                                    .frame(height: 300)
                            @unknown default:
                                defaultSportImage
                            }
                        }
                    }
                    .fullScreenCover(isPresented: $showingFullScreenImage) {
                        ZStack {
                            Color.black.edgesIgnoringSafeArea(.all)
                            
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .edgesIgnoringSafeArea(.all)
                                case .failure(_):
                                    defaultSportImage
                                case .empty:
                                    ProgressView()
                                @unknown default:
                                    defaultSportImage
                                }
                            }
                            
                            VStack {
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        showingFullScreenImage = false
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 30))
                                            .foregroundColor(.white)
                                            .padding()
                                    }
                                }
                                Spacer()
                            }
                        }
                    }
                } else {
                    defaultSportImage
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text(hir.cim)
                        .font(.system(size: 24, weight: .bold))
                        .padding(.horizontal)
                    
                    Text(hir.letrehozasDatum.formatDateToSingleLine())
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    Text(hir.tartalom)
                        .font(.system(size: 16))
                        .lineSpacing(6)
                        .padding(.horizontal)
                    
                    // Link gomb visszaadása
                    if let url = findURL(in: hir.tartalom) {
                        Link(destination: url) {
                            HStack {
                                Image(systemName: "link")
                                    .font(.system(size: 16))
                                Text("Link megnyitása")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            .foregroundColor(.blue)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.blue, lineWidth: 1)
                            )
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                }
                .padding(.vertical)
            }
        }
        .background(Color(.systemBackground))
        .edgesIgnoringSafeArea(.top)
    }
    
    // URL kereső függvény visszaadása
    private func findURL(in text: String) -> URL? {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector?.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
        
        if let match = matches?.first, let range = Range(match.range, in: text) {
            let urlString = String(text[range])
            return URL(string: urlString)
        }
        return nil
    }
    
    private var defaultSportImage: some View {
        ZStack {
            Color(.systemGray6)
            Image(systemName: "newspaper.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(.blue.opacity(0.5))
        }
        .frame(height: 300)
    }
}

struct HirCard: View {
    let hir: Hir
    @Binding var selectedHir: Hir?
    @Binding var showingDetail: Bool
    
    var body: some View {
        Button(action: {
            selectedHir = hir
            showingDetail = true
        }) {
            VStack(alignment: .leading, spacing: 12) {
                if let kepUrl = hir.kep,
                   let url = URL(string: kepUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 200)
                                .clipped()
                        case .failure(_):
                            defaultSportImage
                        case .empty:
                            ProgressView()
                                .frame(height: 200)
                        @unknown default:
                            defaultSportImage
                        }
                    }
                } else {
                    defaultSportImage
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(hir.cim)
                        .font(.system(size: 18, weight: .semibold))
                        .lineLimit(2)
                    
                    Text(hir.letrehozasDatum.formatDateToSingleLine())
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var defaultSportImage: some View {
        ZStack {
            Color(.systemGray6)
            Image(systemName: "newspaper.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(.blue.opacity(0.5))
        }
        .frame(height: 200)
    }
}

#Preview {
    HirekView() 
}
