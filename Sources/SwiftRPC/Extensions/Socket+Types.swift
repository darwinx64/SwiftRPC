//
//  Socket+Types.swift
//  SwiftRPC
//
//  Created by tiramisu on 2025.05.19.
//

import Socket

public extension Socket {
	
	// MARK: - Structs
	struct Error: Swift.Error {
		let code: Int
		let message: String
		init(code: Int, message: String) {
			self.code = code
			self.message = message
		}
		init(from response: Response) {
			guard
				let errorBody = response.data["data"] as? [String: Any],
				let code = errorBody["code"] as? Int,
				let message = errorBody["message"] as? String
			else {
				self.code = -1
				self.message = "Unknown error"
				return
			}
			self.code = code
			self.message = message
		}
	}
	struct Event {
		let type: `Type`
		let response: Response

		public enum `Type`: String {
			// Don't subscribe to these manually
			case error = "ERROR"
			case ready = "READY"
			
			// Opt-in, can be subscribed to
			case join = "ACTIVITY_JOIN"
			case joinRequest = "ACTIVITY_JOIN_REQUEST"
			case spectate = "ACTIVITY_SPECTATE"
		}
	}
	struct Response {
		let data: [String: Any] // Decoded JSON
		let opcode: Opcode
	}
	
	// MARK: - Enums
	enum Command {
		case handshake
		case setActivity
		case setSubscription(Event.`Type`)
	}
	enum Opcode: UInt32 {
		case handshake
		case frame
		case close
		case ping
		case pong
	}
}
