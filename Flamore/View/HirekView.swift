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
    @State private var isLoadingDetail = false
    @State private var errorMessage: String?
    @State private var selectedHir: Hir?
    @State private var showingDetail = false
    @State private var showAllNews = false
    
    var displayedHirek: [Hir] {
        if showAllNews {
            return hirek
        } else {
            return Array(hirek.prefix(4))
        }
    }
    
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
                    if showAllNews {
                        Button(action: {
                            withAnimation {
                                showAllNews = false
                                scrollToTop()
                            }
                        }) {
                            HStack {
                                Text("Összes bezárása")
                                Image(systemName: "chevron.up")
                            }
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                    
                    LazyVStack(spacing: 20) {
                        ForEach(displayedHirek) { hir in
                            Button(action: {
                                if !isLoading {
                                    isLoadingDetail = true
                                    selectedHir = hir
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        showingDetail = true
                                    }
                                }
                            }) {
                                HirCard(hir: hir)
                            }
                            .buttonStyle(CardButtonStyle())
                            .disabled(isLoading)
                        }
                    }
                    .padding(.horizontal)
                    
                    if hirek.count > 4 && !showAllNews {
                        Button(action: {
                            withAnimation {
                                showAllNews = true
                            }
                        }) {
                            HStack {
                                Text("További hírek")
                                Image(systemName: "chevron.down")
                            }
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
        .background(Color(.systemBackground))
        .sheet(isPresented: $showingDetail) {
            if let hir = selectedHir {
                HirDetailView(hir: hir, isLoading: $isLoadingDetail)
            }
        }
        .onAppear {
            loadHirek()
        }
    }
    
    private func loadHirek() {
        isLoading = true
        fetchHirek()
    }
    
    private func fetchHirek() {
        isLoading = true
        
        guard let url = URL(string: "http://192.168.0.178:3000/api/hirek") else {
            print("URL hiba")
            isLoading = false
            return
        }
        
        let urlRequest = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Hálózati hiba: \(error.localizedDescription)")
                    self.isLoading = false
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    print("Szerver hiba")
                    self.isLoading = false
                    return
                }
                
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .iso8601
                        let hirekResponse = try decoder.decode([Hir].self, from: data)
                        self.hirek = hirekResponse
                        print("Betöltött hírek száma: \(hirekResponse.count)")
                    } catch {
                        print("Dekódolási hiba: \(error)")
                    }
                }
                
                self.isLoading = false
            }
        }.resume()
    }
    
    private func scrollToTop() {
        let windows = UIApplication.shared.windows
        windows.forEach { window in
            window.rootViewController?.view.setNeedsLayout()
        }
    }
}

// Egyedi button style a kártyákhoz
struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

struct HirCard: View {
    let hir: Hir
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Kép
            if let kepUrl = hir.kep, let url = URL(string: kepUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                            .clipped()
                    case .failure(_):
                        defaultSportImage
                    case .empty:
                        ProgressView()
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemGray6))
                    @unknown default:
                        defaultSportImage
                    }
                }
            } else {
                defaultSportImage
            }
            
            VStack(alignment: .leading, spacing: 12) {
                // Dátum és klub egy sorban
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                            .foregroundColor(.blue)
                            .imageScale(.small)
                        Text(hir.letrehozasDatum.formatDateToSingleLine())
                            .foregroundColor(.secondary)
                    }
                    .font(.system(size: 14, weight: .medium))
                    
                    Spacer()
                    
                    Text("Castrum Sc")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                
                // Cím
                Text(hir.cim)
                    .font(.system(size: 22, weight: .bold))
                    .lineSpacing(4)
                    .padding(.horizontal, 16)
                
                // Rövid leírás
                Text(hir.tartalom)
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .lineSpacing(4)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
            }
            .padding(16)
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 2)
    }
    
    private var defaultSportImage: some View {
        Image(systemName: "figure.martial.arts")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .background(Color(.systemGray6))
            .foregroundColor(.blue)
    }
}

struct HirDetailView: View {
    let hir: Hir
    @Binding var isLoading: Bool
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Kép
                        if let kepUrl = hir.kep, let url = URL(string: kepUrl) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 300)
                                        .frame(maxWidth: .infinity)
                                        .clipped()
                                        .onAppear {
                                            isLoading = false
                                        }
                                case .failure(_):
                                    defaultSportImage
                                        .onAppear {
                                            isLoading = false
                                        }
                                case .empty:
                                    ProgressView()
                                        .frame(height: 300)
                                        .frame(maxWidth: .infinity)
                                        .background(Color(.systemGray6))
                                @unknown default:
                                    defaultSportImage
                                        .onAppear {
                                            isLoading = false
                                        }
                                }
                            }
                        } else {
                            defaultSportImage
                                .onAppear {
                                    isLoading = false
                                }
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            // Dátum és klub egy sorban
                            HStack {
                                HStack(spacing: 6) {
                                    Image(systemName: "clock")
                                        .foregroundColor(.blue)
                                        .imageScale(.small)
                                    Text(hir.letrehozasDatum.formatDateToSingleLine())
                                        .foregroundColor(.secondary)
                                }
                                .font(.system(size: 14, weight: .medium))
                                
                                Spacer()
                                
                                Text("Castrum Sc")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            .padding(.horizontal, 20)
                            
                            // Cím
                            Text(hir.cim)
                                .font(.system(size: 28, weight: .bold))
                                .lineSpacing(4)
                            
                            // Teljes leírás
                            Text(hir.tartalom)
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                                .lineSpacing(6)
                            
                            // Link gomb
                            if let url = findURL(in: hir.tartalom) {
                                Button(action: {
                                    UIApplication.shared.open(url)
                                }) {
                                    HStack {
                                        Image(systemName: "link")
                                            .imageScale(.medium)
                                        Text("Link megnyitása")
                                            .fontWeight(.semibold)
                                    }
                                    .frame(height: 44)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
                                .padding(.top, 8)
                            }
                        }
                        .padding(.vertical, 20)
                    }
                }
                
                if isLoading {
                    Color.black.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                        .overlay(
                            ProgressView()
                                .scaleEffect(1.5)
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        )
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
                    .imageScale(.large)
                    .frame(width: 44, height: 44)
            })
        }
    }
    
    private var defaultSportImage: some View {
        Image(systemName: "figure.martial.arts")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: .infinity)
            .frame(height: 300)
            .background(Color(.systemGray6))
            .foregroundColor(.blue)
    }
    
    private func findURL(in text: String) -> URL? {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector?.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
        
        if let match = matches?.first, let range = Range(match.range, in: text) {
            let urlString = String(text[range])
            return URL(string: urlString)
        }
        return nil
    }
}

#Preview {
    HirekView() 
}
