struct Hir: Identifiable, Decodable {
    let id: Int
    let cim: String
    let tartalom: String
    let kep: String?
    let klubId: Int
    let letrehozasDatum: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case cim
        case tartalom
        case kep
        case klubId = "klub_id"
        case letrehozasDatum = "letrehozas_datum"
    }
}