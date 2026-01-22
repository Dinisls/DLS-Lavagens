import Foundation
import SwiftUI
import FirebaseFirestore
import Combine

class ClientesViewModel: ObservableObject {
    @Published var clientes: [Cliente] = []
    private var db = Firestore.firestore()
    
    init() {
        fetchData()
    }
    
    // Ficar à escuta da lista de clientes
    func fetchData() {
        db.collection("clientes")
            .order(by: "nome", descending: false) // Ordem alfabética
            .addSnapshotListener { (querySnapshot, error) in
                guard let documents = querySnapshot?.documents else { return }
                
                self.clientes = documents.compactMap { snapshot -> Cliente? in
                    return try? snapshot.data(as: Cliente.self)
                }
            }
    }
    
    // Adicionar novo cliente (se ainda não existir)
    func adicionarClienteSeNaoExistir(nome: String, telefone: String) {
        // Verifica se já existe alguém com este nome exato
        if clientes.contains(where: { $0.nome.lowercased() == nome.lowercased() }) {
            return // Já existe, não faz nada
        }
        
        let novo = Cliente(nome: nome, telefone: telefone, dataCriacao: Date())
        
        do {
            try db.collection("clientes").addDocument(from: novo)
        } catch {
            print("Erro ao guardar cliente: \(error)")
        }
    }
    
    // Apagar cliente
    func apagarCliente(cliente: Cliente) {
        if let id = cliente.id {
            db.collection("clientes").document(id).delete()
        }
    }
}
