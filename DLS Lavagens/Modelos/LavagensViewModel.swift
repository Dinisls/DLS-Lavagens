import Foundation
import SwiftUI
import Combine // <--- IMPORTANTE
import FirebaseFirestore

class LavagensViewModel: ObservableObject {
    @Published var lavagens: [Lavagem] = []
    private var db = Firestore.firestore()
    
    init() {
        fetchData()
    }
    
    // Ler dados
    func fetchData() {
        db.collection("lavagens")
            .order(by: "data", descending: true)
            .addSnapshotListener { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else { return }
                
                self.lavagens = documents.compactMap { snapshot -> Lavagem? in
                    return try? snapshot.data(as: Lavagem.self)
                }
            }
    }
    
    // Adicionar
    func adicionarLavagem(lavagem: Lavagem) {
        do {
            try db.collection("lavagens").addDocument(from: lavagem)
        } catch {
            print("Erro ao guardar lavagem: \(error)")
        }
    }
    
    // Apagar
    func apagarLavagem(lavagem: Lavagem) {
        if let id = lavagem.id {
            db.collection("lavagens").document(id).delete()
        }
    }
}
