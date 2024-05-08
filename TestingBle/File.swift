//
//  File.swift
//  TestingBle
//
//  Created by sang on 27/4/24.
//

import Foundation
import CoreBluetooth

protocol BLEManagerDelegate: AnyObject {
    func bleManager(_ bleManager: BLEManager, didDiscoverPeripheral peripheral: CBPeripheral)
    func bleManager(_ bleManager: BLEManager, didConnectToPeripheral peripheral: CBPeripheral)
    func bleManager(_ bleManager: BLEManager, didReceiveData data: Data)
}

class BLEManager: NSObject {
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral?
    private var characteristic: CBCharacteristic?
    weak var delegate: BLEManagerDelegate?
    private var writeCharacteristic : CBCharacteristic!
    private  var readCharacteristic : CBCharacteristic!

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func startScanning() {
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }

    func connect(to peripheral: CBPeripheral) {
        self.peripheral = peripheral
        centralManager.connect(peripheral, options: nil)
    }

    func disconnect() {
        if let peripheral = peripheral {
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }

    func write(data: Data) {
        if let peripheral = peripheral, let characteristic = characteristic {
            peripheral.writeValue(data, for: characteristic, type: .withResponse)
        }
    }
    func readData() {
        print("KKKjjjjj")
        if let peripheral = peripheral, let characteristic = self.readCharacteristic {
               peripheral.readValue(for: characteristic)
           }
       }
}

extension BLEManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            startScanning()
        } else {
            // Handle other states
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        delegate?.bleManager(self, didDiscoverPeripheral: peripheral)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        delegate?.bleManager(self, didConnectToPeripheral: peripheral)
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        // Handle disconnection
    }
}

extension BLEManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let servicePeripheral = peripheral.services {
            for service in servicePeripheral {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characterArray = service.characteristics {
            for cc in characterArray {
                if(cc.uuid.uuidString == "49535343-8841-43F4-A8D4-ECBE34729BB3") {
                    self.writeCharacteristic = cc
                    print("getttt")
                }
                if(cc.uuid.uuidString == "FEC9") {
                    self.readCharacteristic = cc
                    print("getttt")
                    peripheral.readValue(for: self.readCharacteristic)
                    peripheral.setNotifyValue(true, for: self.readCharacteristic)
                    
                }
            }
        }
       
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let data = characteristic.value {
            delegate?.bleManager(self, didReceiveData: data)
            print(data)
        }
    }
}
