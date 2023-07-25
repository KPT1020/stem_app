//
//  ContentView.swift
//  BLEScanner
//
//  Created by Christian Möller on 02.01.23.
//

import SwiftUI
import CoreBluetooth


struct ContentView: View {
    @ObservedObject  var bluetoothScanner: BluetoothScanner //obtain updated info from bluetoothScanner
    @State private var searchText = ""
    @State private var isActive=false
    var studentname:String
    
    var body: some View {
        NavigationView{
            VStack {
                HStack {
                    // Text field for entering search text
                    TextField("Search", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    // Button for clearing search text
                    Button(action: {
                        self.searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .opacity(searchText == "" ? 0 : 1)
                }
                .padding()
                
                // List of discovered peripherals filtered by search text
                List(bluetoothScanner.discoveredPeripherals.filter {
                    self.searchText.isEmpty ? true : $0.peripheral.name?.lowercased().contains(self.searchText.lowercased()) == true
                }, id: \.peripheral.identifier) { discoveredPeripheral in
                    VStack(alignment: .leading) {
                        Text(discoveredPeripheral.peripheral.name ?? "Unknown Device")
                        Text(discoveredPeripheral.advertisedData)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    HStack{
                      
                        Button(action: {
                            //connect to the selected peripheral
                            bluetoothScanner.connect(to: discoveredPeripheral.peripheral)
                            if bluetoothScanner.isConnecting {
                                isActive=true
                            }else{
                                isActive=false
                            }
                        }){
                            Text("Connect")
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .disabled(bluetoothScanner.isScanning)
                        
                    }
                }
                
                // Button for starting or stopping scanning
                Button(action: {
                    if self.bluetoothScanner.isScanning {
                        self.bluetoothScanner.stopScan()
                    } else {
                        self.bluetoothScanner.startScan()
                    }
                }) {
                    //label
                    if bluetoothScanner.isScanning {
                        Text("Stop Scanning")
                    } else {
                        Text("Scan for Devices")
                    }
                }
                // Button looks cooler this way on iOS
                .padding()
                .background(bluetoothScanner.isScanning ? Color.red : Color.blue)
                .foregroundColor(Color.white)
                .cornerRadius(5.0)
                NavigationLink(destination: ConnectedView(bluetoothScanner: bluetoothScanner), isActive: $isActive){
                  //  EmptyView()
                   
                }
            }
            
        }
     
    }
}

struct ConnectedView: View{
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var bluetoothScanner : BluetoothScanner
   
    
    var body: some View{
        NavigationStack{
            VStack{
                
                Text("Connected!")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                
                Text("Received data:"+(bluetoothScanner.currdata ?? "no data"))
                    .font(.body)
                    .fontWeight(.semibold)
                    .padding()
                    .multilineTextAlignment(.center)
                
                Button(action:{
                    bluetoothScanner.isConnecting=false
                    self.presentationMode.wrappedValue.dismiss()
                    
                }){
                    Text("disconnect")
                }
                .padding()
                .onReceive(bluetoothScanner.$isConnecting) { connected in
                    if !connected {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                 
                }
                
             

                
                
            }
        }
      
    }
}
