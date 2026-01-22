import SwiftUI
import FirebaseFirestore

// Estrutura para cada linha de diluição (ex: "Borrifador - 50ml - 1:10")
struct Diluicao: Identifiable, Codable, Hashable {
    var id = UUID()
    var uso: String        // Ex: "Uso padrão", "Borrifador"
    var quantidade: String // Ex: "30ml", "50ml"
    var detalhe: String    // Ex: "por 1L", "1:10", "1:5"
    var isRatio: Bool      // Se for verdadeiro, mostra na "caixinha" (badge)
}

struct Produto: Identifiable, Codable {
    @DocumentID var id: String?
    var nome: String       // Ex: "GS - APC"
    var sigla: String      // Ex: "GS-APC" (o que aparece na etiqueta colorida)
    var corHex: String     // Código da cor da etiqueta (ex: "blue", "purple", "orange")
    var diluicoes: [Diluicao]
}
