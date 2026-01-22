import Foundation
import Combine
import FirebaseFirestore

class ProdutosViewModel: ObservableObject {
    @Published var produtos: [Produto] = []
    private var db = Firestore.firestore()
    
    init() {
        fetchData()
    }
    
    func fetchData() {
        db.collection("produtos")
            .order(by: "nome", descending: false)
            .addSnapshotListener { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else { return }
                self.produtos = documents.compactMap { try? $0.data(as: Produto.self) }
            }
    }
    
    // CRIAR NOVO
    func adicionarProduto(produto: Produto) {
        do {
            _ = try db.collection("produtos").addDocument(from: produto)
        } catch {
            print("Erro ao adicionar: \(error)")
        }
    }
    
    // ATUALIZAR EXISTENTE (A função nova que resolve o problema)
    func atualizarProduto(produto: Produto) {
        if let id = produto.id {
            do {
                try db.collection("produtos").document(id).setData(from: produto)
            } catch {
                print("Erro ao atualizar: \(error)")
            }
        }
    }
    
    // APAGAR
    func apagarProduto(produto: Produto) {
        if let id = produto.id {
            db.collection("produtos").document(id).delete()
        }
    }
}
