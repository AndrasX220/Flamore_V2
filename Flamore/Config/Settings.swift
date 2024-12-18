struct Settings {
    static let baseURL = "http://192.168.0.178:3000"
    
    struct API {
        static let termek = "\(baseURL)/api/termek"
        static let edzesek = "\(baseURL)/api/edzesek"
        static let resztvevok = "\(baseURL)/api/resztvevok"
        static let letszam = "\(baseURL)/api/letszam"
        static let login = "\(baseURL)/api/login"
        static let register = "\(baseURL)/api/register"
        
        // Dinamikus URL-ek
        static func edzesResztvevok(edzesId: Int) -> String {
            return "\(baseURL)/api/edzes/\(edzesId)/resztvevok"
        }
        
        static func edzesLetszam(edzesId: Int) -> String {
            return "\(baseURL)/api/edzes/\(edzesId)/letszam"
        }
    }
} 