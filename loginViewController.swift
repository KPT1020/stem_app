//
//  loginViewController.swift
//  iosBleSdkTestApp
//
//  Created by K i on 14/8/2023.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift
enum AuthenticationState {
  case unauthenticated
  case authenticating
  case authenticated
}
enum AuthenticationFlow {
  case login
  case signUp
}
@MainActor
class loginViewController: ObservableObject {
  @Published var email: String = ""
  @Published var password: String = ""
  @Published var confirmPassword: String = ""
  @Published var flow: AuthenticationFlow = .login
  @Published var isValid: Bool  = false
  @Published var authenticationState: AuthenticationState = .unauthenticated
  @Published var errorMessage: String = ""
  @Published var user: User?
  @Published var displayName: String = ""
    
  init() {
    registerAuthStateHandler()
    $flow
      .combineLatest($email, $password, $confirmPassword)
      .map { flow, email, password, confirmPassword in
        flow == .login
        ? !(email.isEmpty || password.isEmpty)
        : !(email.isEmpty || password.isEmpty || confirmPassword.isEmpty)
      }
      .assign(to: &$isValid)
  }
    
  private var authStateHandler: AuthStateDidChangeListenerHandle?
  func registerAuthStateHandler() {
    if authStateHandler == nil {
      authStateHandler = Auth.auth().addStateDidChangeListener { auth, user in
        self.user = user
        self.authenticationState = user == nil ? .unauthenticated : .authenticated
        self.displayName = user?.email ?? ""
      }
    }
  }
    
  func switchFlow() {
    flow = flow == .login ? .signUp : .login
    errorMessage = ""
  }
  private func wait() async {
    do {
      print("Wait")
      try await Task.sleep(nanoseconds: 1_000_000_000)
      print("Done")
    }
    catch { }
  }
    
  func reset() {
    flow = .login
    email = ""
    password = ""
    confirmPassword = ""
  }
}

extension loginViewController{
    
    func signInWithGoogle() async->Bool {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            fatalError("No client ID found in Firebase configuration")
        }
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else{
            print("There is no root view controller")
            return false
        }
        do{
            
            let userAuthentication = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            let user = userAuthentication.user
            guard let idToken = user.idToken else{
              //  throw AuthError.tokenError(message: "ID token missing")
                return true
            }
            let accessToken = user.accessToken
            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken.tokenString)
            let result = try await Auth.auth().signIn(with: credential)
            let firebaseUser = result.user
            print("User \(firebaseUser.uid) signed in with email \(firebaseUser.email ?? "unknown")")
        }catch{
            print(error.localizedDescription)
           // errorMessage = error.localizedDescription
            return true
        }
        return false
    }
}

extension loginViewController {
    func signInWithGoogle() {
        func signInWithGoogle() async -> Bool {
            return false  // replace this with the implementation
        }
    }
}
