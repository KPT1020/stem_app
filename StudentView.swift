//
//  StudentView.swift
//  BLEScanner
//
//  Created by K i on 21/7/2023.
//

import SwiftUI
import CoreBluetooth

struct StudentView: View {
    @State var students = [String]()
    @State var newStudent = ""
    @State var showSheet = false
    @ObservedObject var scannerManager = BluetoothScannerManager()
    @State var currindex:Int = -1
    
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(students.indices, id: \.self) { index in
                        if !students[index].isEmpty {
                            HStack {
                                
                                
                                
                                Spacer()
                                
                                NavigationLink {
                                    if !scannerManager.scanners.isEmpty && index <= self.currindex{
                                        
                                        ContentView(bluetoothScanner: scannerManager.scanners[index])
                                        
                                        
                                    }
                                    
                                } label: {
                                    Text(students[index])
                                        .onAppear(){
                                            self.currindex+=1
                                            self.scannerManager.addScanner(studentname: students[index])
                                            
                                        }
                                }
                                
                                Spacer()
                                
                                
                                
                                
                            }
                            .id(index)
                        }
                        
                    }
                }
            }
            .navigationTitle("Student")
            
            HStack {
                Spacer()
                TextField("ADD NEW STUDENT", text: $newStudent)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onAppear {
                        UIApplication.shared.sendAction(#selector(UIResponder.becomeFirstResponder), to: nil, from: nil, for: nil)
                    }
                Button("Add") {
                    if !newStudent.isEmpty{
                        students.append(newStudent)
                    }
                    
                    newStudent = ""
                }
                Spacer()
            }
        }
        .environmentObject(scannerManager)
    }
    
    
    
    
    
    
    
    
}


struct StudentView_Previews: PreviewProvider {
    static var previews: some View {
        StudentView()
    }
}
