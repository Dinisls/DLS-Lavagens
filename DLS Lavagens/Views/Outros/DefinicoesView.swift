import SwiftUI
import FirebaseFirestore

struct DefinicoesView: View {
    @Environment(\.dismiss) var dismiss
    @State private var mostrarAlertaReset = false
    @State private var aApagar = false
    
    var body: some View {
        NavigationStack {
            List {
                // --- SECÇÃO DE DADOS ---
                Section(header: Text("Gestão de Dados")) {
                    Button(role: .destructive) {
                        mostrarAlertaReset = true
                    } label: {
                        if aApagar {
                            HStack {
                                Text("A apagar...")
                                Spacer()
                                ProgressView()
                            }
                        } else {
                            Label("Reset Total aos Dados", systemImage: "trash.fill")
                        }
                    }
                }
                
                // --- SECÇÃO SOBRE ---
                Section(header: Text("Sobre")) {
                    HStack {
                        Text("Versão")
                        Spacer()
                        Text("1.0.1")
                            .foregroundColor(.gray)
                    }
                    
                    HStack {
                        Text("Desenvolvido por")
                        Spacer()
                        Text("DLS Inc")
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("Definições")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Concluído") { dismiss() }
                }
            }
            // --- ALERTA DE CONFIRMAÇÃO ---
            .alert("Apagar TUDO?", isPresented: $mostrarAlertaReset) {
                Button("Cancelar", role: .cancel) { }
                Button("Sim, Apagar Tudo", role: .destructive) {
                    apagarTudo()
                }
            } message: {
                Text("Esta ação não pode ser desfeita. Vai apagar todas as lavagens, compras, clientes e registos financeiros.")
            }
        }
    }
    
    // --- LÓGICA DE APAGAR ---
    func apagarTudo() {
        aApagar = true
        let db = Firestore.firestore()
        let colecoes = ["lavagens", "compras", "clientes", "retiradas"]
        
        let group = DispatchGroup()
        
        for colecao in colecoes {
            group.enter()
            db.collection(colecao).getDocuments { (snapshot, error) in
                guard let documents = snapshot?.documents else {
                    group.leave()
                    return
                }
                
                for document in documents {
                    db.collection(colecao).document(document.documentID).delete()
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            aApagar = false
            dismiss() // Fecha a janela quando acabar
        }
    }
}
