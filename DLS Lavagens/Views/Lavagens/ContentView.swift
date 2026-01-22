import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = LavagensViewModel()
    @State private var mostrarFormulario = false
    @State private var mostrarDefinicoes = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Fundo Azul Escuro
                Color(red: 0.1, green: 0.13, blue: 0.23).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    // --- CABEÇALHO ---
                    HStack {
                        Text("Lavagens")
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
                        
                        // Botão Adicionar
                        Button(action: { mostrarFormulario = true }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.blue)
                                .background(Color.white.clipShape(Circle()))
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .padding(.bottom, 10)
                    
                    // --- LISTA ---
                    if viewModel.lavagens.isEmpty {
                        VStack {
                            Spacer()
                            Image(systemName: "car.side.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            Text("Sem lavagens registadas")
                                .foregroundColor(.gray)
                                .padding()
                            Spacer()
                        }
                    } else {
                        List {
                            ForEach(viewModel.lavagens) { lavagem in
                                VStack(alignment: .leading, spacing: 10) {
                                    // Linha 1: Nome e Matrícula
                                    HStack {
                                        Text(lavagem.clienteNome.isEmpty ? "Cliente Indefinido" : lavagem.clienteNome)
                                            .font(.headline).bold().foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        if !lavagem.matricula.isEmpty {
                                            Text(lavagem.matricula)
                                                .font(.caption).fontWeight(.semibold)
                                                .padding(.horizontal, 8).padding(.vertical, 4)
                                                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.white.opacity(0.5), lineWidth: 1))
                                                .foregroundColor(.white)
                                        }
                                    }
                                    
                                    // Linha 2: Serviço e Data
                                    HStack {
                                        Text(lavagem.tipoServico).font(.subheadline).foregroundColor(.gray)
                                        Spacer()
                                        Text(lavagem.data, format: .dateTime.day().month(.abbreviated)).font(.caption).foregroundColor(.gray)
                                    }
                                    
                                    Divider().background(Color.gray.opacity(0.5))
                                    
                                    // Linha 3: Preço
                                    HStack {
                                        Spacer()
                                        Text(lavagem.valor, format: .currency(code: "EUR"))
                                            .font(.title3).bold().foregroundStyle(.green)
                                    }
                                }
                                .padding()
                                .background(Color(red: 0.15, green: 0.18, blue: 0.28))
                                .cornerRadius(12)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        viewModel.apagarLavagem(lavagem: lavagem)
                                    } label: {
                                        Label("Apagar", systemImage: "trash.fill")
                                    }
                                }
                            }
                        }
                        .scrollContentBackground(.hidden)
                        .listStyle(.plain)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $mostrarFormulario) {
                NovaLavagemView()
            }
            .sheet(isPresented: $mostrarDefinicoes) {
                DefinicoesView()
            }
        }
    }
}
