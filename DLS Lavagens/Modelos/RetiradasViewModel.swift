import Foundation
import SwiftUI
import Combine
import FirebaseFirestore

class RetiradasViewModel: ObservableObject {
    @Published var retiradas: [Retirada] = []
    private var db = Firestore.firestore()
    
    init() {
        fetchData()
    }
    
    func fetchData() {
        db.collection("retiradas")
            .order(by: "data", descending: true)
            .addSnapshotListener { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else { return }
                self.retiradas = documents.compactMap { try? $0.data(as: Retirada.self) }
            }
    }
    
    func adicionarRetirada(valor: Double) {
        let nova = Retirada(valor: valor, data: Date(), observacao: "Levantamento")
        
        // CORREÇÃO: Usar '_ =' para dizer ao Swift que sabemos que devolve algo, mas não precisamos.
        do {
            _ = try db.collection("retiradas").addDocument(from: nova)
        } catch {
            print("Erro ao adicionar retirada: \(error)")
        }
    }
    
    func apagarRetirada(retirada: Retirada) {
        if let id = retirada.id {
            db.collection("retiradas").document(id).delete()
        }
    }
}
