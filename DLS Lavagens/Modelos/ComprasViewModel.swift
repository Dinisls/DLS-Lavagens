import Foundation
import FirebaseFirestore

class ComprasViewModel: ObservableObject {
    @Published var compras: [Compra] = []
    private var db = Firestore.firestore()
    
    init() {
        fetchData() // Começa logo à escuta quando abres a app
    }
    
    // 1. Receber dados em tempo real
    func fetchData() {
        db.collection("compras")
            .order(by: "data", descending: true)
            .addSnapshotListener { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else {
                    print("Nenhum documento encontrado")
                    return
                }
                // Converte os dados da Google para a nossa estrutura 'Compra'
                self.compras = documents.compactMap { queryDocumentSnapshot -> Compra? in
                    return try? queryDocumentSnapshot.data(as: Compra.self)
                }
            }
    }
    
    // 2. Adicionar Compra
    func adicionarCompra(compra: Compra) {
        do {
            try db.collection("compras").addDocument(from: compra)
        } catch {
            print("Erro ao guardar: \(error.localizedDescription)")
        }
    }
    
    // 3. Apagar Compra
    func apagarCompra(compra: Compra) {
        if let documentoId = compra.id {
            db.collection("compras").document(documentoId).delete()
        }
    }
}