//
//  BluetoothScannerManager.swift
//  BLEScanner
//
//  Created by K i on 25/7/2023.
//

import Foundation
import CoreBluetooth

class BluetoothScannerManager: ObservableObject {
    @Published var scanners = [BluetoothScanner]()
  
   
   
    
    func addScanner(studentname: String) {
        let scanner = BluetoothScanner(name: studentname)
        print(scanner.studentname ?? "none")
        scanners.append(scanner)
    }
}
