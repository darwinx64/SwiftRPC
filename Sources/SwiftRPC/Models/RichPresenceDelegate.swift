//
//  RichPresenceDelegate.swift
//  SwiftRPC
//
//  Created by tiramisu on 2025.05.19.
//

import Foundation
import Socket

open class RichPresenceDelegate {
	open var id: String
	open var activity: Activity
	open var subscriptions: [Socket.Event.`Type`]?
	
	public init(id: String, activity: Activity, subscriptions: [Socket.Event.`Type`]? = nil) {
		self.id = id
		self.activity = activity
		self.subscriptions = subscriptions
	}
	
	internal var _activity: [String: Any] {
		let encoder = JSONEncoder()
		encoder.keyEncodingStrategy = .convertToSnakeCase
		
		do {
			let data = try encoder.encode(activity)
			let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
			let dictionary = jsonObject as! [String: Any]
			return dictionary
		} catch {
			fatalError("Could not encode activity\n\n\(error)")
		}
	}
	
#if os(macOS)
	open func richPresence(postChange name: Notification.Name) {
		NotificationCenter.default.post(name: name, object: self)
	}
#endif
	open func richPresence(responseTo error: any Error) {
		fatalError("\(error)")
	}
	open func richPresence(responseTo event: Socket.Event) throws -> Socket.Response? {
		switch event.type {
			case .error:
				let error = Socket.Error(from: event.response)
				throw error
			case .ready:
				return richPresence(responseTo: .setActivity)
			default:
				return nil
		}
	}
	open func richPresence(responseTo command: Socket.Command) -> Socket.Response {
		switch command {
			case .handshake:
				return .init(
					data: [
						"v": 1,
						"client_id": id
					],
					opcode: .handshake
				)
			case .setActivity:
				return .init(
					data: [
						"cmd": "SET_ACTIVITY",
						"args": [
							"pid": ProcessInfo.processInfo.processIdentifier,
							"activity": _activity
						],
						"nonce": UUID().uuidString
					],
					opcode: .frame
				)
			case .setSubscription(let subscription):
				return .init(
					data: [
						"cmd": "SUBSCRIBE",
						"evt": subscription,
						"nonce": UUID().uuidString
					],
					opcode: .frame
				)
		}
	}
	open func richPresence(responseTo response: Socket.Response) throws -> Socket.Response? {
		switch response.opcode {
			case .close:
				let error = Socket.Error(from: response)
				throw error
			case .frame:
				guard
					let _eventType = response.data["evt"] as? String
				else { return nil }
				let event = Socket.Event(type: .init(rawValue: _eventType)!, response: response)
				return try richPresence(responseTo: event)
			case .ping:
				return response
			default:
				return nil
		}
	}
}
