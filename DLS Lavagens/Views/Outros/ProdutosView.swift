import SwiftUI

struct ProdutosView: View {
    @StateObject var viewModel = ProdutosViewModel()
    @State private var mostrarFormulario = false
    @State private var mostrarDefinicoes = false
    
    // Variável para controlar qual produto estamos a editar
    @State private var produtoParaEditar: Produto?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.1, green: 0.13, blue: 0.23).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    // --- CABEÇALHO ---
                    HStack {
                        Image(systemName: "flask.fill").foregroundColor(.white)
                        Text("Guia de Produtos").font(.largeTitle).bold().foregroundColor(.white)
                        Spacer()
                        Button(action: { mostrarDefinicoes = true }) {
                            Image(systemName: "gearshape.fill").font(.title2).foregroundColor(.white.opacity(0.8))
                                .padding(8).background(Color.white.opacity(0.1)).clipShape(Circle())
                        }
                        Button(action: {
                            produtoParaEditar = nil // Garante que é um novo
                            mostrarFormulario = true
                        }) {
                            Image(systemName: "plus.circle.fill").font(.system(size: 30)).foregroundColor(.blue)
                                .background(Color.white.clipShape(Circle()))
                        }
                    }
                    .padding(.horizontal).padding(.vertical, 10)
                    
                    // --- LISTA COM SWIPE TO DELETE ---
                    if viewModel.produtos.isEmpty {
                        VStack { Spacer(); Text("Sem produtos registados.").foregroundColor(.gray); Spacer() }
                    } else {
                        List {
                            ForEach(viewModel.produtos) { produto in
                                CartaoProduto(produto: produto) {
                                    // Ação do Lápis (Editar)
                                    produtoParaEditar = produto
                                    mostrarFormulario = true
                                }
                                // Estilos para remover o visual padrão da Lista
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                // AÇÃO DE APAGAR (ARRASTAR)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        viewModel.apagarProduto(produto: produto)
                                    } label: {
                                        Label("Apagar", systemImage: "trash.fill")
                                    }
                                }
                            }
                        }
                        .listStyle(.plain) // Remove estilos extra da lista
                        .scrollContentBackground(.hidden) // Remove fundo cinza da lista
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $mostrarFormulario) {
                // Passamos o produtoParaEditar (se for nil é novo, se tiver valor é edição)
                NovoProdutoView(viewModel: viewModel, produtoParaEditar: produtoParaEditar)
            }
            .sheet(isPresented: $mostrarDefinicoes) {
                DefinicoesView()
            }
        }
    }
}

// --- DESIGN DO CARTÃO ---
struct CartaoProduto: View {
    let produto: Produto
    var acaoEditar: () -> Void // Função que é chamada quando clicamos no lápis
    
    var corBadge: Color {
        switch produto.corHex {
        case "green": return Color(red: 0.2, green: 0.8, blue: 0.4)
        case "purple": return Color(red: 0.6, green: 0.4, blue: 0.9)
        case "orange": return .orange
        case "red": return .red
        case "pink": return .pink
        default: return .blue
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            
            // 1. Cabeçalho
            HStack {
                Text(produto.sigla)
                    .font(.caption).bold()
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(corBadge).foregroundColor(.white).cornerRadius(4)
                
                if produto.diluicoes.isEmpty {
                    Text(produto.nome).font(.headline).foregroundColor(.white).padding(.leading, 5)
                }
                
                Spacer()
                
                // BOTÃO LÁPIS (EDITAR)
                Button(action: acaoEditar) {
                    Image(systemName: "pencil")
                        .font(.body) // Aumentei um pouco para ser mais fácil clicar
                        .foregroundColor(.gray)
                        .padding(5) // Área de toque maior
                }
                .buttonStyle(BorderlessButtonStyle()) // Importante para não ativar o clique da célula inteira
            }
            
            // 2. Dados
            if !produto.diluicoes.isEmpty {
                VStack(spacing: 15) {
                    ForEach(produto.diluicoes) { diluicao in
                        HStack(alignment: .center) {
                            Text(diluicao.uso).font(.subheadline).foregroundColor(.gray)
                            Spacer()
                            HStack(spacing: 6) {
                                // ADICIONADO "ml" AQUI
                                Text("\(diluicao.quantidade)ml")
                                    .font(.subheadline).bold()
                                    .foregroundColor(Color(red: 0.3, green: 0.6, blue: 1.0))
                                
                                if diluicao.isRatio {
                                    Text(diluicao.detalhe)
                                        .font(.caption2).padding(.horizontal, 6).padding(.vertical, 2)
                                        .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color(red: 0.6, green: 0.4, blue: 0.9), lineWidth: 1))
                                        .foregroundColor(Color(red: 0.6, green: 0.4, blue: 0.9))
                                } else {
                                    Text(diluicao.detalhe).font(.caption).foregroundColor(.gray)
                                }
                                
                                // Lápis decorativo removido daqui pois já temos o editar em cima
                            }
                        }
                        if diluicao.id != produto.diluicoes.last?.id {
                            Divider().background(Color.gray.opacity(0.2))
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(Color(red: 0.15, green: 0.18, blue: 0.28))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.white.opacity(0.05), lineWidth: 1))
    }
}
