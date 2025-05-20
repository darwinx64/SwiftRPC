//
//  Socket+Send.swift
//  SwiftRPC
//
//  Created by tiramisu on 2025.05.19.
//

import Socket
import Foundation

internal extension Socket {
	func send(_ message: Socket.Response) throws {
		let json = try JSONSerialization.data(withJSONObject: message.data, options: [])
		
		var header = Data()
		var opRaw = UInt32(message.opcode.rawValue).littleEndian
		var length = UInt32(json.count).littleEndian
		
		withUnsafeBytes(of: &opRaw) { header.append(contentsOf: $0) }
		withUnsafeBytes(of: &length) { header.append(contentsOf: $0) }
		
		var buffer = header
		buffer.append(json)
		
		try buffer.withUnsafeBytes {
			guard let baseAddress = $0.baseAddress else { return }
			try write(from: baseAddress, bufSize: buffer.count)
		}
	}
}
