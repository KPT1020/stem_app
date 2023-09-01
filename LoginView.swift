//
//  LoginView.swift
//  iosBleSdkTestApp
//
//  Created by K i on 11/8/2023.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift

struct LoginView: View {

    @State var email=""
    @State var password = ""
    @State var userIsLogin = false
    @State var StatusMessage = ""
    @StateObject var viewModel: loginViewController = loginViewController()
    @Environment(\.dismiss) var dismiss
    
    private func signInWithGoogle() {
       viewModel.signInWithGoogle()
       Task {
         if await viewModel.signInWithGoogle() == true {
           dismiss()
         }
       }
     }
    
    var body: some View {
        
        if userIsLogin {
            BottomView()
        }else{
            content
        }
        
    }
    
    var content: some View{
        ZStack{
            Image("swift design")
                .resizable()
                //.aspectRatio(contentMode: .fill)
            VStack{
                 
                Text("Welcome!")
                    .foregroundColor(.white)
                    .bold()
                    .font(.largeTitle)
                    .offset(x: -100,y: -150)
                
                Text(self.StatusMessage)
                    .bold()
                    .foregroundColor(.black)
                  
                
                HStack{
                    Image(systemName: "envelope")
                        .foregroundColor(.white)
                    
                    TextField("Email", text: $email)
                        .foregroundColor(.white)
                        .textFieldStyle(.plain)
                        .placeholder(when: email.isEmpty, placeholder: {
                            Text("Email")
                                .foregroundColor(.white)

                        })
                        .onAppear {
                            UIApplication.shared.sendAction(#selector(UIResponder.becomeFirstResponder), to: nil, from: nil, for: nil)
                        }
                }
               
                Rectangle()
                    .frame(width:350, height:1)
                    .foregroundColor(.white)
                    .padding(10)
                HStack{
                    Image(systemName: "lock")
                        .foregroundColor(.white)
                    SecureField("Password", text:$password)
                        .foregroundColor(.white)
                        .textFieldStyle(.plain)
                        .placeholder(when: password.isEmpty) {
                            Text("Password")
                                .foregroundColor(.white)
                        }

                }
            
                Rectangle()
                    .frame(width:350, height:1)
                    .foregroundColor(.white)
                    .padding(10)
            
                
               
                Button {
                    register()
                } label: {
                    Text("Sign Up")
                        .bold()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.skyBlue)
                        )
                        .padding()
                     
                }
                
                Button {
                    login()
                } label: {
                    Text("Already have an account? Login")
                        .foregroundColor(.blue)
                   
                }
                
                LabelledDivider(label: "or")
                
//                Button {
//                   signInWithGoogle
//                } label: {
//                    Text("Sign in with Google")
//                        .frame(maxWidth: .infinity)
//                        .foregroundColor(.black)
//                        .padding(.vertical)
//                        .background(alignment: .leading) {
//                            Image("google")
//                                .frame(width:40,alignment: .center)
//                        }
//                }
//                .buttonStyle(.bordered)
                Button(action: { self.signInWithGoogle() }) {
                    Button(action: signInWithGoogle) {
                        Text("Sign in with Google")
                             .frame(maxWidth: .infinity)
                            .foregroundColor(.black)
                            .padding(.vertical)
                            .background(alignment: .leading) {
                                Image("google")
                                    .frame(width:40,alignment: .center)
                            }
                    }
                    
                }
                .buttonStyle(.bordered)
              
                

                

            }
            .frame(width:350)
            .padding()
            .onAppear{
                Auth.auth().addStateDidChangeListener { auth, user in
                    if user != nil {
                        print("User exists")
                        userIsLogin = true
                     
                    }
                }
            }
            
        
    
            
        }
        .ignoresSafeArea()
        
    }
    
    private func register(){
        Auth.auth().createUser(withEmail: email, password: password){ result,error in
            if error != nil {
                print(error!.localizedDescription)
                self.StatusMessage="\(error!.localizedDescription)"
            }
        }
    }
    
    private func login(){
        Auth.auth().signIn(withEmail: email, password: password){ result,error in
            if error != nil {
                print(error!.localizedDescription)
                self.StatusMessage="\(error!.localizedDescription)"
            }else{
                self.StatusMessage="Successfully logged in"
            }
            
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        
        LoginView()
        
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

extension Color {
    static let skyBlue = Color(red: 0.0, green: 0.5, blue: 1.0)
}

struct LabelledDivider: View {

    let label: String
    let horizontalPadding: CGFloat
    let color: Color

    init(label: String, horizontalPadding: CGFloat = 20, color: Color = .black) {
        self.label = label
        self.horizontalPadding = horizontalPadding
        self.color = color
    }

    var body: some View {
        HStack {
            line
            Text(label).foregroundColor(color)
            line
        }
    }

    var line: some View {
        VStack { Divider().background(color) }.padding(horizontalPadding)
    }
}
