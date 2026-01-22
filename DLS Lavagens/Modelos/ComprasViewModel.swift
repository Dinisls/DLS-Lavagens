import Foundation
import SwiftUI
import Combine // <--- ESTA ERA A PEÇA EM FALTA
import FirebaseFirestore

class ComprasViewModel: ObservableObject {
    @Published var compras: [Compra] = []
    private var db = Firestore.firestore()
    
    init() {
        fetchData()
    }
    
    // Ler dados
    func fetchData() {
        db.collection("compras")
            .order(by: "data", descending: true)
            .addSnapshotListener { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else { return }
                
                self.compras = documents.compactMap { snapshot -> Compra? in
                    return try? snapshot.data(as: Compra.self)
                }
            }
    }
    
    // Adicionar
    func adicionarCompra(compra: Compra) {
        do {
            try db.collection("compras").addDocument(from: compra)
        } catch {
            print("Erro ao guardar: \(error)")
        }
    }
    
    // Apagar
    func apagarCompraEspecifica(compra: Compra) {
        if let id = compra.id {
            db.collection("compras").document(id).delete()
        }
    }
}
