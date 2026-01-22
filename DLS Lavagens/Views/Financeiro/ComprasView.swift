import SwiftUI

struct ComprasView: View {
    @StateObject var viewModel = ComprasViewModel()
    @State private var mostrarDefinicoes = false
    
    // Dados do Formulário
    @State private var tipo: String = "Produto"
    @State private var valor: Double = 0.0
    @State private var descricao: String = ""
    @State private var dataCompra: Date = Date()
    @State private var quemPagou: String = "AFP"
    
    let tiposDisponiveis = ["Produto", "Equipamento", "Outros"]
    let pagadores = ["AFP", "Dinis"]
    
    // Filtros e Cálculos
    var comprasDoMes: [Compra] {
        let calendar = Calendar.current
        return viewModel.compras.filter { calendar.isDate($0.data, equalTo: dataCompra, toGranularity: .month) }
    }
    
    var comprasDinis: [Compra] { comprasDoMes.filter { $0.quemPagou == "Dinis" } }
    var comprasAFP: [Compra] { comprasDoMes.filter { $0.quemPagou == "AFP" } }
    
    var totalDinis: Double { comprasDinis.reduce(0) { $0 + $1.valor } }
    var totalAFP: Double { comprasAFP.reduce(0) { $0 + $1.valor } }
    
    var tituloMes: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_PT")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: dataCompra)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.1, green: 0.13, blue: 0.23).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // --- CABEÇALHO ---
                        HStack {
                            Image(systemName: "cart")
                            Text("Compras - \(tituloMes)")
                                .font(.headline)
                            
                            Spacer()
                            
                            Button(action: { mostrarDefinicoes = true }) {
                                Image(systemName: "gearshape.fill")
                                    .font(.title3)
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(8)
                                    .background(Color.white.opacity(0.1))
                                    .clipShape(Circle())
                            }
                        }
                        .foregroundColor(.white)
                        .padding(.top)
                        
                        // --- FORMULÁRIO ---
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Nova Compra").font(.headline).bold()
                            
                            HStack {
                                Menu {
                                    ForEach(tiposDisponiveis, id: \.self) { t in Button(t) { tipo = t } }
                                } label: {
                                    HStack { Text(tipo); Spacer(); Image(systemName: "chevron.down") }
                                    .padding().background(Color.gray.opacity(0.1)).cornerRadius(8).foregroundColor(.black)
                                }
                                
                                TextField("", value: $valor, format: .currency(code: "EUR"), prompt: Text("Valor (€)").foregroundColor(.gray))
                                    .keyboardType(.decimalPad)
                                    .padding()
                                    .background(Color(red: 0.1, green: 0.1, blue: 0.2))
                                    .cornerRadius(8)
                                    .foregroundColor(.white)
                            }
                            
                            TextField("", text: $descricao, prompt: Text("Descrição (opcional)").foregroundColor(.gray))
                                .padding()
                                .background(Color(red: 0.1, green: 0.1, blue: 0.2))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                            
                            HStack {
                                DatePicker("", selection: $dataCompra, displayedComponents: .date)
                                    .labelsHidden().padding().background(Color(red: 0.1, green: 0.1, blue: 0.2)).cornerRadius(8).colorScheme(.dark)
                                
                                Picker("Pagador", selection: $quemPagou) {
                                    ForEach(pagadores, id: \.self) { p in Text(p) }
                                }
                                .pickerStyle(.segmented).background(Color.white).cornerRadius(8)
                            }
                            
                            Button(action: adicionarCompra) {
                                HStack { Image(systemName: "plus"); Text("Adicionar Compra") }
                                .frame(maxWidth: .infinity).padding().background(Color.black.opacity(0.8)).foregroundColor(.white).cornerRadius(8)
                            }
                        }
                        .padding().background(Color.white).cornerRadius(12)
                        
                        // --- TOTAIS ---
                        HStack(spacing: 15) {
                            cartaoTotal(titulo: "Compras Dinis", valor: totalDinis, cor: .blue, fundo: Color(red: 0.1, green: 0.2, blue: 0.4))
                            cartaoTotal(titulo: "Compras AFP", valor: totalAFP, cor: .green, fundo: Color(red: 0.1, green: 0.3, blue: 0.2))
                        }
                        
                        // --- LISTAS ---
                        listaCompras(titulo: "Dinis", cor: .blue, lista: comprasDinis)
                        listaCompras(titulo: "AFP", cor: .green, lista: comprasAFP)
                        
                        Spacer().frame(height: 50)
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $mostrarDefinicoes) {
                DefinicoesView()
            }
        }
    }
    
    func adicionarCompra() {
        let novaCompra = Compra(data: dataCompra, descricao: descricao.isEmpty ? tipo : descricao, valor: valor, tipo: tipo, quemPagou: quemPagou)
        viewModel.adicionarCompra(compra: novaCompra)
        valor = 0.0; descricao = ""
    }
    
    func cartaoTotal(titulo: String, valor: Double, cor: Color, fundo: Color) -> some View {
        VStack {
            Text(titulo).font(.caption).opacity(0.8)
            Text(valor, format: .currency(code: "EUR")).font(.title2).bold()
        }
        .frame(maxWidth: .infinity).padding()
        .background(fundo).overlay(RoundedRectangle(cornerRadius: 10).stroke(cor, lineWidth: 1))
        .foregroundColor(.white).cornerRadius(10)
    }
    
    func listaCompras(titulo: String, cor: Color, lista: [Compra]) -> some View {
        VStack(alignment: .leading) {
            Text(titulo).font(.caption).bold().padding(5).background(cor).foregroundColor(.white).cornerRadius(5)
            
            if lista.isEmpty {
                Text("Sem compras este mês").frame(maxWidth: .infinity, alignment: .center).padding().foregroundColor(.gray)
            } else {
                // CORREÇÃO: Usamos 'id: \.self' porque a Compra agora é Hashable
                ForEach(lista, id: \.self) { compra in
                    HStack {
                        // Formatação da Data simplificada para evitar erros
                        Text(compra.data.formatted(.dateTime.day().month(.twoDigits)))
                            .font(.system(size: 14)).foregroundColor(.gray).frame(width: 50, alignment: .leading)
                        
                        Text(compra.descricao).font(.system(size: 14)).frame(maxWidth: .infinity, alignment: .leading)
                        Text(compra.valor, format: .currency(code: "EUR")).font(.system(size: 14, weight: .bold))
                        
                        Button(action: { viewModel.apagarCompra(compra: compra) }) {
                            Image(systemName: "trash").foregroundColor(.red).font(.caption)
                        }.padding(.leading, 10)
                    }
                    .padding(.vertical, 8)
                    Divider()
                }
            }
        }
        .padding().background(Color.white).cornerRadius(12)
    }
}
