//
//  SettingView.swift
//  iosBleSdkTestApp
//
//  Created by K i on 15/8/2023.
//

import SwiftUI
import FirebaseAuth

struct SettingView: View {
    @Binding var islogout:Bool
   // @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack{
            Button {
                logout()
            } label: {
                Text("Log out")
                    .foregroundColor(.white)
                    .bold()
                    .frame(width: 100, height: 40)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                    )
                    
            }
            
        }
            
        
        
    }
        
    func logout(){
        do{
            
            try Auth.auth().signOut()
            islogout=true
            
        }catch let err {
            
            print(err)
        }
    }
}

//struct SettingView_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingView(islogout: <#Binding<Bool>#>)
//    }
//}
