import SwiftUI

struct ClientesView: View {
    @StateObject var clientesVM = ClientesViewModel()
    @StateObject var lavagensVM = LavagensViewModel()
    @State private var textoPesquisa: String = ""
    @State private var mostrarDefinicoes = false
    
    var clientesFiltrados: [Cliente] {
        if textoPesquisa.isEmpty { return clientesVM.clientes }
        else { return clientesVM.clientes.filter { $0.nome.localizedCaseInsensitiveContains(textoPesquisa) } }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.1, green: 0.13, blue: 0.23).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    // --- CABEÇALHO ---
                    HStack {
                        Text("Clientes")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Botão Definições
                        Button(action: { mostrarDefinicoes = true }) {
                            Image(systemName: "gearshape.fill")
                                .font(.title2)
                                .foregroundColor(.white.opacity(0.8))
                                .padding(8)
                                .background(Color.white.opacity(0.1))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .padding(.bottom, 10)
                    
                    // --- CONTEÚDO ---
                    if clientesVM.clientes.isEmpty {
                        VStack {
                            Spacer(); Text("Ainda não há clientes.").foregroundColor(.gray); Spacer()
                        }
                    } else {
                        ScrollView {
                            VStack(spacing: 15) {
                                // Barra Pesquisa
                                HStack {
                                    Image(systemName: "magnifyingglass").foregroundColor(.gray)
                                    TextField("Pesquisar por nome...", text: $textoPesquisa).foregroundColor(.white)
                                }
                                .padding()
                                .background(Color(red: 0.15, green: 0.18, blue: 0.28))
                                .cornerRadius(12)
                                .padding(.horizontal)
                                
                                ForEach(clientesFiltrados) { cliente in
                                    CartaoCliente(cliente: cliente, lavagens: lavagensVM.lavagens)
                                }
                                Spacer().frame(height: 50)
                            }
                            .padding(.top)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $mostrarDefinicoes) {
                DefinicoesView()
            }
        }
    }
}

struct CartaoCliente: View {
    let cliente: Cliente
    let lavagens: [Lavagem]
    var lavagensDoCliente: [Lavagem] { lavagens.filter { $0.clienteNome.lowercased() == cliente.nome.lowercased() } }
    var totalGasto: Double { lavagensDoCliente.reduce(0) { $0 + $1.valor } }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(cliente.nome).font(.headline).foregroundColor(.white)
                Spacer()
                Text("\(lavagensDoCliente.count) lavagens")
                    .font(.caption).padding(5)
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.white, lineWidth: 1))
                    .foregroundColor(.white)
            }
            HStack {
                Image(systemName: "phone.fill").font(.caption)
                Text(cliente.telefone.isEmpty ? "Sem telefone" : cliente.telefone).font(.caption)
            }.foregroundColor(.gray)
            
            Divider().background(Color.gray)
            HStack { Spacer(); Text("Total: \(String(format: "%.2f €", totalGasto))").foregroundStyle(.green).bold() }
        }
        .padding().background(Color(red: 0.15, green: 0.18, blue: 0.28)).cornerRadius(12).padding(.horizontal)
    }
}
