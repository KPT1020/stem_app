//
//  devicemanager.swift
//  iosBleSdkTestApp
//
//  Created by K i on 1/8/2023.
//

import Foundation
import CoreBluetooth
import SwiftUI


class DeviceManagers: ObservableObject {
    @Published var devices = [String:PolarBleSdkManager]()
   // @Published var devices = [PolarBleSdkManager]()

   
    func addDevice(studentname:String) {
        if devices[studentname] == nil{
            let device = PolarBleSdkManager(studentname: studentname)
             devices[studentname]=device
        }
   
    }

//    func moveDevice(indices:IndexSet, newOffset:Int){
//        devices.move(fromOffsets: indices, toOffset: newOffset)
//    }
//
 
}


