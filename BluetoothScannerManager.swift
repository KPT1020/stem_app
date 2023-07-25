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

    func addScanner() {
        let scanner = BluetoothScanner()
        scanners.append(scanner)
    }
}
