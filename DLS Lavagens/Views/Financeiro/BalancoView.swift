import SwiftUI
import Charts
import UniformTypeIdentifiers

struct BalancoView: View {
    @StateObject var lavagensVM = LavagensViewModel()
    @StateObject var comprasVM = ComprasViewModel()
    @StateObject var retiradasVM = RetiradasViewModel()
    
    @State private var dataSelecionada = Date()
    @State private var valorRetirar: Double = 0.0
    @State private var mostrarDefinicoes = false
    
    // Filtros Mensais
    var lavagensDoMes: [Lavagem] {
        let calendar = Calendar.current
        return lavagensVM.lavagens.filter {
            calendar.isDate($0.data, equalTo: dataSelecionada, toGranularity: .month) &&
            calendar.isDate($0.data, equalTo: dataSelecionada, toGranularity: .year)
        }
    }
    var comprasDoMes: [Compra] {
        let calendar = Calendar.current
        return comprasVM.compras.filter {
            calendar.isDate($0.data, equalTo: dataSelecionada, toGranularity: .month) &&
            calendar.isDate($0.data, equalTo: dataSelecionada, toGranularity: .year)
        }
    }
    
    var receitasMes: Double { lavagensDoMes.reduce(0) { $0 + $1.valor } }
    var despesasMes: Double { comprasDoMes.reduce(0) { $0 + $1.valor } }
    var lucroMes: Double { receitasMes - despesasMes }
    
    // Dados Gráficos
    struct DadosServico: Identifiable { let id = UUID(); let nome: String; let quantidade: Int; let total: Double; let cor: Color }
    var estatisticasServicos: [DadosServico] {
        let agrupado = Dictionary(grouping: lavagensDoMes, by: { $0.tipoServico })
        return agrupado.map { (nome, lavagens) in
            DadosServico(nome: nome, quantidade: lavagens.count, total: lavagens.reduce(0) { $0 + $1.valor }, cor: corDoServico(nome))
        }.sorted { $0.total > $1.total }
    }
    var distribuicaoCompras: [(pagador: String, total: Double)] {
        let agrupado = Dictionary(grouping: comprasDoMes, by: { $0.quemPagou })
        return agrupado.map { (key, value) in (key, value.reduce(0) { $0 + $1.valor }) }
    }
    
    // Totais AFP
    var totalRecebidoAFP: Double { lavagensVM.lavagens.filter { $0.quemRecebeu == "AFP" }.reduce(0) { $0 + $1.valor } }
    var totalRetirado: Double { retiradasVM.retiradas.reduce(0) { $0 + $1.valor } }
    var afpDeveAcumulado: Double { totalRecebidoAFP - totalRetirado }

    // Exportar CSV
    var csvFile: CSVFile {
        var csvString = "Data,Tipo,Descricao,Valor\n"
        for l in lavagensDoMes { csvString += "\(l.data.formatted(date: .numeric, time: .omitted)),Receita,\(l.matricula) (\(l.tipoServico)),\(String(format: "%.2f", l.valor))\n" }
        for c in comprasDoMes { csvString += "\(c.data.formatted(date: .numeric, time: .omitted)),Despesa,\(c.descricao),-\(String(format: "%.2f", c.valor))\n" }
        csvString += "\n,,,Lucro: \(String(format: "%.2f", lucroMes))\n"
        return CSVFile(initialText: csvString)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.1, green: 0.13, blue: 0.23).ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // 1. SELETOR DE MÊS + BOTÃO DEFINIÇÕES
                        HStack {
                            Button(action: { mudarMes(por: -1) }) {
                                Image(systemName: "chevron.left").font(.title3).padding().background(Color.white.opacity(0.1)).cornerRadius(10).foregroundColor(.white)
                            }
                            Spacer()
                            VStack(spacing: 2) {
                                Text(dataSelecionada, format: .dateTime.year()).font(.caption).foregroundColor(.gray)
                                Text(dataSelecionada, format: .dateTime.month(.wide)).font(.title2).bold().foregroundColor(.white).textCase(.uppercase)
                            }
                            .onTapGesture { dataSelecionada = Date() }
                            Spacer()
                            Button(action: { mudarMes(por: 1) }) {
                                Image(systemName: "chevron.right").font(.title3).padding().background(Color.white.opacity(0.1)).cornerRadius(10).foregroundColor(.white)
                            }
                            
                            // Botão Definições
                            Button(action: { mostrarDefinicoes = true }) {
                                Image(systemName: "gearshape.fill")
                                    .font(.title3)
                                    .padding()
                                    .background(Color.blue.opacity(0.6))
                                    .cornerRadius(10)
                                    .foregroundColor(.white)
                            }
                            .padding(.leading, 5)
                        }
                        .padding(.horizontal).padding(.top)
                        
                        // 2. EXPORTAR
                        ShareLink(item: csvFile, preview: SharePreview("Relatório DLS")) {
                            HStack { Image(systemName: "square.and.arrow.up"); Text("Exportar para Excel") }
                                .frame(maxWidth: .infinity).padding().background(Color(red: 0.1, green: 0.6, blue: 0.3)).foregroundColor(.white).cornerRadius(8)
                        }
                        .padding(.horizontal)
                        
                        // 3. RESUMO MENSAL
                        VStack(spacing: 10) {
                            CartaoResumo(titulo: "Receitas", valor: receitasMes, subtexto: "\(lavagensDoMes.count) lavagens", cor: .green, icone: "arrow.up.right")
                            HStack(spacing: 10) {
                                CartaoResumo(titulo: "Despesas", valor: despesasMes, subtexto: "Compras", cor: .red, icone: "arrow.down.right")
                                CartaoResumo(titulo: "Lucro", valor: lucroMes, subtexto: "Líquido", cor: .blue, icone: "banknote")
                            }
                        }
                        .padding(.horizontal)
                        
                        Divider().background(Color.gray).padding(.horizontal)
                        
                        // 4. CONTA CORRENTE AFP
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                Image(systemName: "wallet.pass.fill").foregroundColor(.green)
                                Text("Conta Corrente AFP").font(.headline).foregroundColor(.black)
                                Spacer()
                            }
                            .padding().background(Color.white).cornerRadius(12, corners: [.topLeft, .topRight])
                            
                            VStack(alignment: .leading, spacing: 20) {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Disponível para levantar (Acumulado)").font(.caption).foregroundColor(.gray)
                                    Text(afpDeveAcumulado, format: .currency(code: "EUR"))
                                        .font(.system(size: 44, weight: .bold))
                                        .foregroundColor(Color(red: 0.2, green: 0.8, blue: 0.4))
                                }
                                
                                HStack {
                                    TextField("€ Valor", value: $valorRetirar, format: .number)
                                        .keyboardType(.decimalPad).padding().background(Color(red: 0.05, green: 0.08, blue: 0.15))
                                        .cornerRadius(8).foregroundColor(.white)
                                    
                                    Button(action: fazerRetirada) {
                                        Text("Retirar").bold().padding().background(Color(red: 0.4, green: 0.8, blue: 0.6)).foregroundColor(.black).cornerRadius(8)
                                    }.disabled(valorRetirar <= 0)
                                }
                            }
                            .padding().background(Color(red: 0.08, green: 0.1, blue: 0.2)).cornerRadius(12, corners: [.bottomLeft, .bottomRight])
                        }
                        .padding(.horizontal)
                        
                        // 5. HISTÓRICO RETIRADAS
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Histórico de Levantamentos").font(.headline).foregroundColor(.white).padding(.top)
                            if retiradasVM.retiradas.isEmpty { Text("Sem registos.").font(.caption).foregroundColor(.gray) }
                            else {
                                ForEach(retiradasVM.retiradas) { retirada in
                                    HStack {
                                        Image(systemName: "arrow.turn.right.up").foregroundColor(.red).font(.caption)
                                        Text(retirada.data, format: .dateTime.day().month().year()).font(.subheadline).foregroundColor(.gray)
                                        Spacer()
                                        Text("-\(retirada.valor, format: .currency(code: "EUR"))").bold().foregroundColor(.white)
                                        Button(action: { retiradasVM.apagarRetirada(retirada: retirada) }) {
                                            Image(systemName: "trash").foregroundColor(.red.opacity(0.7)).font(.caption)
                                        }
                                    }
                                    .padding().background(Color(red: 0.15, green: 0.18, blue: 0.28)).cornerRadius(8)
                                }
                            }
                        }.padding(.horizontal)
                        
                        // 6. GRÁFICOS E LISTAS
                        graficoBarrasView
                        listaResumoServicosView
                        graficoComprasView
                        
                        Spacer().frame(height: 50)
                    }
                    .padding(.bottom)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $mostrarDefinicoes) { DefinicoesView() }
        }
    }
    
    // Sub-Views e Funções
    var graficoBarrasView: some View {
        VStack(alignment: .leading) {
            Text("Lavagens por Serviço").font(.headline).foregroundColor(.white).padding(.bottom, 5)
            Chart(estatisticasServicos) { item in
                BarMark(x: .value("Serviço", item.nome), y: .value("Total", item.quantidade))
                    .foregroundStyle(item.cor)
                    .annotation(position: .top) { Text("\(item.quantidade)").font(.caption).foregroundColor(.gray) }
            }
            .frame(height: 200).chartBackground { _ in Color.clear }.padding().background(Color.white).cornerRadius(12)
        }.padding(.horizontal)
    }
    
    var listaResumoServicosView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Resumo por Serviço").font(.headline).foregroundColor(.white)
            VStack(spacing: 2) {
                ForEach(estatisticasServicos) { item in
                    HStack {
                        Text(item.nome).font(.caption).bold().padding(.horizontal, 8).padding(.vertical, 4).background(item.cor).foregroundColor(.white).cornerRadius(6)
                        Text("x\(item.quantidade)").font(.subheadline).foregroundColor(.white)
                        Spacer()
                        Text(item.total, format: .currency(code: "EUR")).bold().foregroundColor(.white)
                    }.padding().background(Color(red: 0.15, green: 0.18, blue: 0.28))
                    if item.id != estatisticasServicos.last?.id { Divider().background(Color.gray.opacity(0.2)) }
                }
            }.cornerRadius(12)
        }.padding(.horizontal)
    }
    
    var graficoComprasView: some View {
        VStack(alignment: .leading) {
            Text("Distribuição de Compras").font(.headline).foregroundColor(.white).padding(.bottom, 5)
            HStack {
                Chart(distribuicaoCompras, id: \.pagador) { item in
                    SectorMark(angle: .value("Valor", item.total), innerRadius: .ratio(0.6), angularInset: 2)
                        .foregroundStyle(by: .value("Pagador", item.pagador)).cornerRadius(5)
                }.frame(height: 200)
                VStack(alignment: .leading) {
                    ForEach(distribuicaoCompras, id: \.pagador) { item in
                        HStack {
                            Circle().fill(item.pagador == "AFP" ? Color.green : Color.blue).frame(width: 10, height: 10)
                            Text(item.pagador).foregroundColor(.gray).font(.caption)
                            Text(item.total, format: .currency(code: "EUR")).bold().foregroundColor(.white).font(.caption)
                        }
                    }
                }
            }.padding().background(Color.white).cornerRadius(12)
        }.padding(.horizontal)
    }
    
    func mudarMes(por valor: Int) { if let n = Calendar.current.date(byAdding: .month, value: valor, to: dataSelecionada) { dataSelecionada = n } }
    func fazerRetirada() { retiradasVM.adicionarRetirada(valor: valorRetirar); valorRetirar = 0; UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil) }
    func corDoServico(_ nome: String) -> Color {
        switch nome {
        case "Base Completa": return .red
        case "Premium Completa": return .blue
        case "Banhoca": return Color(red: 0.1, green: 0.3, blue: 0.3)
        case "Base Interior": return .pink
        case "Base Exterior": return .orange
        case "Premium Interior": return .gray.opacity(0.5)
        case "Premium Exterior": return .blue.opacity(0.7)
        default: return .gray
        }
    }
}

struct CartaoResumo: View {
    let titulo: String; let valor: Double; let subtexto: String; let cor: Color; let icone: String
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(titulo).font(.caption).bold().opacity(0.8)
                Text(valor, format: .currency(code: "EUR")).font(.title2).bold()
                Text(subtexto).font(.caption).opacity(0.6)
            }
            Spacer(); Image(systemName: icone).font(.title).opacity(0.5)
        }
        .padding().background(cor).foregroundColor(.white).cornerRadius(12)
    }
}

struct CSVFile: Transferable {
    var initialText: String
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .commaSeparatedText) { csv in
            let url = FileManager.default.temporaryDirectory.appendingPathComponent("Relatorio_DLS.csv")
            try csv.initialText.write(to: url, atomically: true, encoding: .utf8)
            return SentTransferredFile(url)
        } importing: { received in
            let text = try String(contentsOf: received.file, encoding: .utf8)
            return CSVFile(initialText: text)
        }
    }
}

extension View { func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View { clipShape(RoundedCorner(radius: radius, corners: corners)) } }
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity; var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
