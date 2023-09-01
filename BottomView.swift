//
//  BottomView.swift
//  iosBleSdkTestApp
//
//  Created by K i on 15/8/2023.
//

import SwiftUI

struct BottomView: View {
    @State var islogout=false
   // @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        NavigationView{
            if islogout {
                LoginView()
            }else{
                TabView {
                    studentview()
                        .tabItem {
                            Image(systemName: "cursorarrow.click.2")
                            Text("Student list")
                        }
                    SettingView(islogout: $islogout)
                        .tabItem{
                            Image(systemName: "person")
                            Text("Setting")
                        }
                }
                
            }
      
        }
    }
}

struct BottomView_Previews: PreviewProvider {
    static var previews: some View {
        BottomView()
    }
}
