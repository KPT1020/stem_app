//
//  ContentView.swift
//  BLEScanner
//
//  Created by Christian Möller on 02.01.23.
//


import SwiftUI
import CoreBluetooth
import Firebase

struct DiscoveredPeripheral {
    // Struct to represent a discovered peripheral
    var peripheral: CBPeripheral
    var advertisedData: String //name,time...
    
}

class BluetoothScanner: NSObject, CBCentralManagerDelegate, ObservableObject,CBPeripheralDelegate {
    @Published var discoveredPeripherals = [DiscoveredPeripheral]() //create a empty DiscoveredPeripheral type array
    @Published var isScanning = false
    @Published var isConnecting = false
    var studentname:String?
    
    
    //manage the Bluetooth scanning process
    var centralManager: CBCentralManager!
    // Set to store unique peripherals that have been discovered
    var discoveredPeripheralSet = Set<CBPeripheral>()
    var timer: Timer?
    var connectedPeripheral: CBPeripheral?
    
    //store peripheral and its timestamp
    var time=[String:String]()
    @Published var currdata:String?
    
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        self.stopScan()
    }
    
    convenience init(name: String) {
        self.init() // call the designated initializer of the subclass
        self.studentname = name
        self.stopScan()
    }
    
    func startScan() {
        print("start scanning")
        if centralManager.state == .poweredOn {
            // Set isScanning to true and clear the discovered peripherals list
            isScanning = true
            discoveredPeripherals.removeAll()
            discoveredPeripheralSet.removeAll()
            objectWillChange.send()
            
            //enter the uuid of esp32
            let esp32uuid=CBUUID(string:"4fafc201-1fb5-459e-8fcc-c5c9c331914b")
            
            
            
            // Start scanning for peripherals
            //withServices:nil means every device nearby will by scanned
            //connecting with esp32
            centralManager.scanForPeripherals(withServices: [esp32uuid])
            // Start a timer to stop and restart the scan every 2 seconds
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] timer in
                self?.centralManager.stopScan()
                self?.centralManager.scanForPeripherals(withServices: [esp32uuid])
            }
        }
    }
    func connect(to peripheral:CBPeripheral){
        centralManager.connect(peripheral,options:nil)
    }
    
    let characteristicUUID = CBUUID(string: "beb5483e-36e1-4688-b7f5-ea07361b26a8")
    
    func centralManager(_ central: CBCentralManager,didConnect peripheral:CBPeripheral){
        print("connected")
        
        self.connectedPeripheral=peripheral
        isConnecting=true
        peripheral.delegate = self
        
        // Discover services containing the characteristic UUID
        let esp32uuid=CBUUID(string:"4fafc201-1fb5-459e-8fcc-c5c9c331914b")
        peripheral.discoverServices([esp32uuid])
        
        self.objectWillChange.send()
    }
    
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("disconnected")
        
        self.connectedPeripheral=nil
        isConnecting=false
        self.objectWillChange.send()
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if peripheral.services?.isEmpty == true {
            
            // No services found with that UUID
            print("No services found")
        }
        
        for service in peripheral.services! {
            
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic in service.characteristics! {
            if characteristic.uuid == characteristicUUID {
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    var i=0
    var dictionary=[String:String]()
    
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        let name:String?=peripheral.name
        var set:String=""
        if let para = time[name ?? ""] {
            set=para
        }
        
        
        if isConnecting {
            
            
            if let data = characteristic.value {
                
                let bytes = [UInt8](data)
                //let data = Data(bytes)
                let values = bytes.map { "\($0)" }
                print("Received data: \(values)")
                dictionary["key\(i)"]=values[0]
                currdata=values[0]
                i+=1
                
            }else{
                return
            }
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: dictionary)
                let jsonObject = try JSONSerialization.jsonObject(with: jsonData)
                print(jsonObject)
                
                
                
                
                let ref = Database.database().reference().child(studentname!).child(set)
                ref.setValue(jsonObject) { (error, ref) in
                    if let error = error {
                        print("Error setting value: \(error.localizedDescription)")
                    } else {
                        print("Value set successfully")
                    }
                }
            } catch {
                print("Error serializing JSON: \(error.localizedDescription)")
            }
            
        }else if !dictionary.isEmpty{
            
            
            
            
            
            
            //reset the dictionary
            dictionary.removeAll()
            i=0
        }
        
        
    }
    
    
    
    
    
    func stopScan() {
        // Set isScanning to false and stop the timer
        print("stop scanning")
        isScanning = false
        timer?.invalidate()
        centralManager.stopScan()
    }
    
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            //print("central.state is .unknown")
            stopScan()
        case .resetting:
            //print("central.state is .resetting")
            stopScan()
        case .unsupported:
            //print("central.state is .unsupported")
            stopScan()
        case .unauthorized:
            //print("central.state is .unauthorized")
            stopScan()
        case .poweredOff:
            //print("central.state is .poweredOff")
            stopScan()
        case .poweredOn:
            //print("central.state is .poweredOn")
            startScan()
        @unknown default:
            print("central.state is unknown")
        }
    }
    
    //only scanning for peripherals,it will be called
    //each time a new matching peripheral is found
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        // Build a string representation of the advertised data and sort it by names
        var advertisedData = advertisementData.map { "\($0): \($1)" }.sorted(by: { $0 < $1 }).joined(separator: "\n")
        
        // Convert the timestamp into human readable format and insert it to the advertisedData String
        let timestampValue = advertisementData["kCBAdvDataTimestamp"] as! Double
        // print(timestampValue)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        let dateString = dateFormatter.string(from: Date(timeIntervalSince1970: timestampValue))
        
        advertisedData = "actual rssi: \(RSSI) dB\n" + "Timestamp: \(dateString)\n" + advertisedData
        
        //storing the time stamp
        time["\(peripheral.name ?? "nil")"]="\(dateString)"
        
        // If the peripheral is not already in the list
        if !discoveredPeripheralSet.contains(peripheral) {
            // Add it to the list and the set
            discoveredPeripherals.append(DiscoveredPeripheral(peripheral: peripheral, advertisedData: advertisedData))
            discoveredPeripheralSet.insert(peripheral)
            objectWillChange.send()
        } else {
            // If the peripheral is already in the list, update its advertised data
            if let index = discoveredPeripherals.firstIndex(where: { $0.peripheral == peripheral }) {
                discoveredPeripherals[index].advertisedData = advertisedData
                objectWillChange.send()
            }
        }
    }
}
