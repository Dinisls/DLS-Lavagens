import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            ComprasView() // Vai buscar ao ficheiro ComprasView.swift
                .tabItem {
                    Label("Compras", systemImage: "cart")
                }
            
            ContentView() // Vai buscar ao ficheiro ContentView.swift (Lista de Lavagens)
                .tabItem {
                    Label("Lavagens", systemImage: "drop.fill")
                }
            
            ProdutosView() // Vai buscar ao ficheiro ProdutosView.swift
                .tabItem {
                    Label("Produtos", systemImage: "flask")
                }
            
            ClientesView() // Vai buscar ao ficheiro ClientesView.swift
                .tabItem {
                    Label("Clientes", systemImage: "person.2")
                }
            
            BalancoView()
                .tabItem {
                    Label("Balanço", systemImage: "calculator") // <--- Ícone Alterado
                }
        }
    }
}
