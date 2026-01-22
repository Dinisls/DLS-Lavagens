import SwiftUI
import FirebaseCore

// Esta classe serve apenas para ligar o Firebase quando a app abre
class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    
    FirebaseApp.configure() // <--- ESTA É A LINHA QUE LIGA A APP À GOOGLE
    
    return true
  }
}

@main
struct DLSLavagensApp: App {
  // Aqui ligamos a classe de cima à estrutura da App
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

  var body: some Scene {
    WindowGroup {
      // Importante: Mantemos o MainTabView para teres os menus em baixo
      // Se pusesses apenas ContentView, perdias a barra de navegação
      MainTabView()
    }
  }
}
