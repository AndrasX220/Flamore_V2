import SwiftUI

struct TeremPicker: View {
    let termek: [Int]
    @Binding var selectedTerem: Int?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                Button(action: {
                    withAnimation(.spring()) {
                        selectedTerem = nil
                    }
                }) {
                    Text("Összes")
                        .font(.system(size: 16, weight: .medium))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(selectedTerem == nil ? 
                                     Color.blue : Color.gray.opacity(0.1))
                        )
                        .foregroundColor(selectedTerem == nil ? .white : .primary)
                }
                
                ForEach(termek, id: \.self) { terem in
                    Button(action: {
                        withAnimation(.spring()) {
                            selectedTerem = terem
                        }
                    }) {
                        Text("Terem \(terem)")
                            .font(.system(size: 16, weight: .medium))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(selectedTerem == terem ? 
                                         Color.blue : Color.gray.opacity(0.1))
                            )
                            .foregroundColor(selectedTerem == terem ? .white : .primary)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }
} 