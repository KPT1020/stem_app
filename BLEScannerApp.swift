//
//  BLEScannerApp.swift
//  BLEScanner
//
//  Created by Christian Möller on 02.01.23.
//


import SwiftUI
import Firebase

@main
struct BLEScannerApp: App {
    
    init() {
          FirebaseApp.configure()
      }
    
    var body: some Scene {
        WindowGroup {
           //  ContentView()
           StudentView()
        }
    }
}
