import Foundation
import FirebaseFirestore

struct Cliente: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var nome: String
    var telefone: String
    var dataCriacao: Date
    
    // O Hashable serve para o Picker (Dropdown) conseguir identificar cada cliente único
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Cliente, rhs: Cliente) -> Bool {
        return lhs.id == rhs.id
    }
}
