import Foundation
import FirebaseFirestore

struct Retirada: Identifiable, Codable {
    @DocumentID var id: String?
    var valor: Double
    var data: Date
    var observacao: String
}
