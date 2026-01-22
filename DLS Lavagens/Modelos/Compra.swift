import Foundation
import FirebaseFirestore

struct Compra: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var data: Date
    var descricao: String
    var valor: Double
    var tipo: String      // "Produto", "Equipamento", "Outros"
    var quemPagou: String // "AFP", "Dinis"
    
    // Identificador seguro para o ForEach (se o ID for nil, usa um UUID temporário)
    var safeId: String {
        return id ?? UUID().uuidString
    }
    
    // Implementação manual do Hashable para evitar erros com o @DocumentID
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(descricao)
        hasher.combine(data)
        hasher.combine(valor)
    }
    
    static func == (lhs: Compra, rhs: Compra) -> Bool {
        return lhs.id == rhs.id &&
               lhs.descricao == rhs.descricao &&
               lhs.data == rhs.data &&
               lhs.valor == rhs.valor
    }
}
