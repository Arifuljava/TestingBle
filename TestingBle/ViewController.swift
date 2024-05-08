//
//  ViewController.swift
//  TestingBle
//
//  Created by sang on 27/4/24.
//

import UIKit
import CoreBluetooth
import Network
import SystemConfiguration.CaptiveNetwork

class ViewController: UIViewController, BLEManagerDelegate, CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
           
           
        } else {
            // Handle other states
        }
    }
    
    func bleManager(_ bleManager: BLEManager, didDiscoverPeripheral peripheral: CBPeripheral) {
        if !discoveredPeripherals.contains(where: { $0.identifier == peripheral.identifier }) {
            discoveredPeripherals.append(peripheral)
            print("Discovered peripheral: \(peripheral.name ?? "Unknown")")
            if let peripheralName = peripheral.name, peripheralName == ble_devies {
                print("Start connecting")
                bleManager.connect(to: peripheral)
            }
        }
    }
    
    func bleManager(_ bleManager: BLEManager, didConnectToPeripheral peripheral: CBPeripheral) {
        print("Connected to peripheral: \(peripheral.name ?? "Unknown")")
    }
    
    func bleManager(_ bleManager: BLEManager, didReceiveData data: Data) {
        var  hexString = data.map { String(format: "%02x", $0) }.joined()
                  print("Buffer String :", hexString)
        
        var adjustedHexValues = ""
                    let hexSubstrings = stride(from: 0, to: hexString.count, by: 2).map {
                        String(hexString[hexString.index(hexString.startIndex, offsetBy: $0)..<hexString.index(hexString.startIndex, offsetBy: $0+2)])
                    }
                    for hexSubstring in hexSubstrings {
                    if let decimalValue = UInt8(hexSubstring, radix: 10) {
                          if decimalValue >= 30
                        {
                              let adjustedValue =  decimalValue - 30
                              adjustedHexValues += String(adjustedValue)
                          }
                            
                        } else {
                            print("Error: Unable to convert hex substring to decimal")
                            return
                        }
                    }
        if let bufferValue  = Int(adjustedHexValues){
            self.buffer_amoount = bufferValue
            print("new  Buffer  Value : ", self.buffer_amoount)
        }
    }
    private var buffer_amoount = 0
    private var ble_devies = "PL-TP874PLUS-DF6A(BLE)"
    private var bleManager: BLEManager?
     var centralManager: CBCentralManager!
    private var discoveredPeripherals: [CBPeripheral] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        print("KKIKIKIKI")
       
        /*
         
         bleManager = BLEManager()
         bleManager?.delegate = self
         bleManager?.startScanning()
         
         */
        // Example usage
        let server = TCPServer()
        server.setupNetworkCommunication(ip_address:  "192.168.0.106") { status in
            switch status {
            case .success:
                print("Connection established successfully.")
                server.sendMessage(message: "Hello, server!")
                if let receivedMessage = server.readMessage() {
                    print("Received message: \(receivedMessage)")
                }
                server.closeConnection()
            case .error:
                print("Failed to establish connection.")
                
            }
            
            
        }
    }
    func scanWifiNetworks() {
            if let interfaces = CNCopySupportedInterfaces() as NSArray? {
                for interface in interfaces {
                    if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                        let ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
                        let bssid = interfaceInfo[kCNNetworkInfoKeyBSSID as String] as? String
                        print("SSID: \(ssid ?? "Unknown"), BSSID: \(bssid ?? "Unknown")")
                    }
                }
            }
        }

}

