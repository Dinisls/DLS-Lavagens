import SwiftUI

struct NovoProdutoView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ProdutosViewModel
    
    // Se tiver valor, é EDIÇÃO. Se for nil, é NOVO.
    var produtoParaEditar: Produto?
    
    // Dados do Produto
    @State private var nome: String = ""
    @State private var sigla: String = ""
    @State private var corSelecionada: String = "blue"
    
    // Dados da Diluição
    @State private var uso: String = ""
    @State private var quantidade: String = ""
    @State private var detalhe: String = ""
    @State private var isRatio: Bool = false
    
    let coresDisponiveis = [
        ("Azul", "blue", Color.blue),
        ("Verde", "green", Color.green),
        ("Roxo", "purple", Color.purple),
        ("Laranja", "orange", Color.orange),
        ("Vermelho", "red", Color.red),
        ("Rosa", "pink", Color.pink)
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Dados do Produto") {
                    TextField("Nome (ex: AutoShampoo)", text: $nome)
                    TextField("Sigla (ex: GSF)", text: $sigla)
                        .textInputAutocapitalization(.characters)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(coresDisponiveis, id: \.1) { item in
                                Circle().fill(item.2).frame(width: 30, height: 30)
                                    .overlay(Circle().stroke(Color.primary, lineWidth: corSelecionada == item.1 ? 2 : 0))
                                    .onTapGesture { corSelecionada = item.1 }
                                    .padding(2)
                            }
                        }
                    }
                }
                
                Section("Configuração da Diluição") {
                    TextField("Uso (ex: Borrifador)", text: $uso)
                    HStack {
                        TextField("Qtd (ex: 50)", text: $quantidade)
                            .keyboardType(.decimalPad)
                        Text("ml").foregroundColor(.gray)
                        Divider()
                        TextField("Detalhe (ex: 1:10)", text: $detalhe)
                    }
                    Toggle("É Proporção (ex: 1:10)?", isOn: $isRatio)
                }
            }
            .navigationTitle(produtoParaEditar == nil ? "Novo Produto" : "Editar Produto")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") { guardarProduto() }
                        .disabled(nome.isEmpty || sigla.isEmpty || uso.isEmpty || quantidade.isEmpty)
                }
            }
            .onAppear {
                // Carregar dados se for edição
                if let p = produtoParaEditar {
                    nome = p.nome
                    sigla = p.sigla
                    corSelecionada = p.corHex
                    if let d = p.diluicoes.first {
                        uso = d.uso
                        quantidade = d.quantidade
                        detalhe = d.detalhe
                        isRatio = d.isRatio
                    }
                }
            }
        }
    }
    
    func guardarProduto() {
        let novaDiluicao = Diluicao(uso: uso, quantidade: quantidade, detalhe: detalhe, isRatio: isRatio)
        
        // CORREÇÃO CRÍTICA AQUI:
        // Se for edição, usamos o ID antigo (produtoParaEditar?.id).
        // Se for novo, o ID é nil e o Firebase cria um novo.
        let produtoFinal = Produto(
            id: produtoParaEditar?.id, // <--- Isto garante que não duplica
            nome: nome,
            sigla: sigla,
            corHex: corSelecionada,
            diluicoes: [novaDiluicao]
        )
        
        if produtoParaEditar != nil {
            // Chama a nova função de atualizar
            viewModel.atualizarProduto(produto: produtoFinal)
        } else {
            // Chama a função de criar novo
            viewModel.adicionarProduto(produto: produtoFinal)
        }
        
        dismiss()
    }
}
