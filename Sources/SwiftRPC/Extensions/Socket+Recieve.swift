//
//  Socket+Recieve.swift
//  SwiftRPC
//
//  Created by tiramisu on 2025.05.19.
//

import Socket
import Foundation

internal extension Socket {
	func recieve() -> Socket.Response? {
		let headerPtr = UnsafeMutablePointer<Int8>.allocate(capacity: 8)
		let headerRawPtr = UnsafeRawPointer(headerPtr)
		
		defer {
			free(headerPtr)
		}
		
		var response = try? read(into: headerPtr, bufSize: 8, truncate: true)
		
		guard response != nil, response! > 0 else {
			return nil
		}
		
		let opValue = headerRawPtr.load(as: UInt32.self)
		let length = headerRawPtr.load(fromByteOffset: 4, as: UInt32.self)
		
		guard length > 0, let op = Socket.Opcode(rawValue: opValue) else {
			return nil
		}
		
		let payloadPtr = UnsafeMutablePointer<Int8>.allocate(capacity: Int(length))
		
		defer {
			free(payloadPtr)
		}
		
		response = try? read(into: payloadPtr, bufSize: Int(length), truncate: true)
		
		guard response != nil, response! > 0 else {
			return nil
		}
		
		let data = Data(bytes: UnsafeRawPointer(payloadPtr), count: Int(length))
		
		guard
			let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
		else { return nil }
		
		return Socket.Response(data: json, opcode: op)
	}
}
