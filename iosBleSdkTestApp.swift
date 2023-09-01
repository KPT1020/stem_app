/// Copyright © 2021 Polar Electro Oy. All rights reserved.

import SwiftUI
import FirebaseCore
import GoogleSignIn
import GoogleSignInSwift

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     open url: URL,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
    
        
        return GIDSignIn.sharedInstance.handle(url)
    }
}
@main
struct iosBleSdkTestApp: App {
   //@StateObject var bleSdkManager = PolarBleSdkManager()
    
    init() {
        FirebaseApp.configure()
    }
    
    
    var body: some Scene {
        WindowGroup {
            LoginView()

 //           studentview()
//            ContentView()
//               .environmentObject(bleSdkManager)
        }
    }
}
