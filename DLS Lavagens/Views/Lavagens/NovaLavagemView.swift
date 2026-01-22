import SwiftUI

struct NovaLavagemView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Motores
    @StateObject var lavagensVM = LavagensViewModel()
    @StateObject var clientesVM = ClientesViewModel() // <--- Novo motor de clientes
    
    // Dados do Formulário
    @State private var servicoSelecionado: String = ""
    @State private var valor: Double = 0.0
    
    // Lógica do Cliente
    @State private var clienteSelecionado: Cliente? = nil // Se nil, é "Novo Cliente"
    @State private var nomeCliente: String = ""
    @State private var telefone: String = ""
    
    @State private var marca: String = ""
    @State private var modelo: String = ""
    @State private var matricula: String = ""
    @State private var quemRecebeu: String = "Dinis"
    @State private var dataLavagem: Date = Date()
    
    // Opções de Serviço
    let servicosOpcoes = [
        ("Base Completa", 25.0, Color.red),
        ("Premium Completa", 35.0, Color.blue),
        ("Banhoca", 10.0, Color(red: 0.1, green: 0.3, blue: 0.3)),
        ("Base Interior", 20.0, Color.pink),
        ("Base Exterior", 10.0, Color.orange),
        ("Premium Interior", 30.0, Color.gray.opacity(0.5)),
        ("Premium Exterior", 15.0, Color.blue.opacity(0.7)),
        ("Lavagem Tapetes", 7.50, Color.brown),
        ("Lavagem Bancos", 10.0, Color.brown.opacity(0.8))
    ]
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // 1. Seleção de Cliente (O que pediste)
                    VStack(alignment: .leading) {
                        Text("Cliente").font(.headline)
                        
                        Menu {
                            // Opção Padrão: Novo Cliente
                            Button(action: {
                                clienteSelecionado = nil
                                nomeCliente = ""
                                telefone = ""
                            }) {
                                Label("Novo Cliente", systemImage: "plus")
                            }
                            
                            Divider()
                            
                            // Lista de Clientes Antigos
                            ForEach(clientesVM.clientes) { cliente in
                                Button(action: {
                                    clienteSelecionado = cliente
                                    nomeCliente = cliente.nome
                                    telefone = cliente.telefone
                                }) {
                                    Text(cliente.nome)
                                }
                            }
                        } label: {
                            HStack {
                                Text(clienteSelecionado == nil ? "+ Novo Cliente" : clienteSelecionado!.nome)
                                    .foregroundColor(clienteSelecionado == nil ? .blue : .primary)
                                    .fontWeight(clienteSelecionado == nil ? .bold : .regular)
                                Spacer()
                                Image(systemName: "chevron.down").foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
                        }
                    }
                    
                    Divider()
                    
                    // 2. Dados do Cliente (Preenchimento)
                    Group {
                        // Se for Novo Cliente, permite editar. Se for antigo, mostra mas pode editar.
                        TextField("Nome do Cliente", text: $nomeCliente)
                        
                        TextField("Telefone", text: $telefone)
                            .keyboardType(.phonePad)
                        
                        TextField("Matrícula (AA-00-BB)", text: $matricula)
                            .textInputAutocapitalization(.characters)
                        
                        HStack {
                            TextField("Marca", text: $marca)
                            TextField("Modelo", text: $modelo)
                        }
                    }
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Divider()
                    
                    // 3. Seleção de Serviços
                    Text("Selecionar Serviços").font(.headline)
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(servicosOpcoes, id: \.0) { servico in
                            Button(action: {
                                self.servicoSelecionado = servico.0
                                self.valor = servico.1
                            }) {
                                VStack {
                                    Text(servico.0).font(.system(size: 14, weight: .bold))
                                    Text(String(format: "%.2f €", servico.1)).font(.caption)
                                }
                                .frame(maxWidth: .infinity, minHeight: 60)
                                .background(servicoSelecionado == servico.0 ? servico.2 : servico.2.opacity(0.6))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.white, lineWidth: servicoSelecionado == servico.0 ? 3 : 0)
                                )
                            }
                        }
                    }
                    
                    Divider()
                    
                    Picker("Quem Recebe", selection: $quemRecebeu) {
                        Text("Dinis").tag("Dinis")
                        Text("AFP").tag("AFP")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    DatePicker("Data", selection: $dataLavagem, displayedComponents: .date)
                    
                }
                .padding()
            }
            .navigationTitle("Nova Lavagem")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Registar") {
                        guardarTudo()
                    }
                    .disabled(nomeCliente.isEmpty || servicoSelecionado.isEmpty)
                }
            }
        }
    }
    
    func guardarTudo() {
        // 1. Se for um cliente novo (ou nome alterado), guardamos na base de dados de Clientes
        if clienteSelecionado == nil {
            clientesVM.adicionarClienteSeNaoExistir(nome: nomeCliente, telefone: telefone)
        }
        
        // 2. Guardar a Lavagem
        let novaLavagem = Lavagem(
            data: dataLavagem,
            matricula: matricula,
            marca: marca,
            modelo: modelo,
            clienteNome: nomeCliente,
            tipoServico: servicoSelecionado,
            valor: valor,
            quemRecebeu: quemRecebeu
        )
        lavagensVM.adicionarLavagem(lavagem: novaLavagem)
        
        dismiss()
    }
}
