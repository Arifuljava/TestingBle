//
//  TCPServer.swift
//  TestingBle
//
//  Created by sang on 4/5/24.
//

import Foundation
import Foundation

class TCPServer {
    var inputStream: InputStream?
    var outputStream: OutputStream?
    
    enum connectionStatus{
        case success
        case error
    }
    
    func setupNetworkCommunication(ip_address : String!, completion: @escaping (connectionStatus) -> Void) {
        var readStream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        CFStreamCreatePairWithSocketToHost(nil, ip_address as CFString, 80, &readStream, &writeStream)
        
        inputStream = readStream!.takeRetainedValue()
        outputStream = writeStream!.takeRetainedValue()
        
        inputStream?.open()
        outputStream?.open()
        
        if inputStream != nil && outputStream != nil {
                    print("Successfully connected to the server.")
            completion(.success)
            print(inputStream)
            print(outputStream)
                } else {
                    print("Failed to establish connection.")
                    completion(.error)
                }
        
    }
    func sendDataForPrint(dataForPrint : Data!) {
        let data = dataForPrint
        _ = data!.withUnsafeBytes { outputStream?.write($0, maxLength: data!.count) }
    }
    
    func sendMessage(message: String) {
        let data = message.data(using: .utf8)!
        _ = data.withUnsafeBytes { outputStream?.write($0, maxLength: data.count) }
    }
    
    func readMessage() -> String? {
        var buffer = [UInt8](repeating: 0, count: 1024)
        guard let inputStream = inputStream else { return nil }
        
        let bytesRead = inputStream.read(&buffer, maxLength: buffer.count)
        guard bytesRead > 0 else { return nil }
        
        return String(bytes: buffer, encoding: .utf8)
    }
    
    func closeConnection() {
        inputStream?.close()
        outputStream?.close()
    }
    func sendData(_ data: Data) {
            _ = data.withUnsafeBytes { outputStream?.write($0, maxLength: data.count) }
        }
}


