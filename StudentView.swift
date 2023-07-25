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
    //@State var currindex:Int=0

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(students.indices, id: \.self) { index in
                        if !students[index].isEmpty {
                            HStack {
                                
                            
                                
                                Spacer()
                                
                                NavigationLink {
                                    if !scannerManager.scanners.isEmpty{
                                        ContentView(bluetoothScanner: scannerManager.scanners[index],studentname: students[index])
                                    }
                                   
                                } label: {
                                    Text(students[index])
                                        .onAppear(){
                                            self.scannerManager.addScanner()
                                        }
                                }

                                Spacer()
//                                Button("Pair") {
//                                    self.currindex=index
//                                    self.showSheet = true
//
//                                }


                           
                            }
                            .id(index)
//                            .sheet(isPresented: $showSheet) {
//                               // Text("the index is \(index) and \(scannerManager.scanners[index])")
//                                ContentView(bluetoothScanner: scannerManager.scanners[index])
                          
//
//                            }
                       
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
                        students.append(newStudent)
                        newStudent = ""
                    }
                    Spacer()
                }
            }
            .environmentObject(scannerManager)
        }
   
        
    
            

        
            
        
    }
}

struct StudentView_Previews: PreviewProvider {
    static var previews: some View {
        StudentView()
    }
}
