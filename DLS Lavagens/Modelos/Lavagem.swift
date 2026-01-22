import Foundation
import FirebaseFirestore

struct Lavagem: Identifiable, Codable {
    @DocumentID var id: String?
    var data: Date
    var matricula: String
    var marca: String
    var modelo: String
    var clienteNome: String
    var tipoServico: String
    var valor: Double
    var quemRecebeu: String // "Dinis" ou "AFP"
}
