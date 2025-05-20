//
//  RichPresence.swift
//  SwiftRPC
//
//  Created by tiramisu on 2025.05.18.
//

import Foundation
import Socket

open class RichPresence {
	open weak var delegate: RichPresenceDelegate?
	open var socket: Socket?
	open var pollTimer: Timer?
	open var receiveTimer: Timer?
	
	public init(delegate: RichPresenceDelegate) {
		self.delegate = delegate
#if os(macOS)
		NotificationCenter.default.addObserver(forName: Activity.DidChange, object: self.delegate, queue: .main) { [weak self] _ in
			do {
				try self?.updatePresence()
			} catch {
				self?.delegate?.richPresence(responseTo: error)
			}
		}
#endif
	}
	
	open func start() throws {
		guard let delegate = delegate else { throw "No delegate" }
		socket = try Socket.create(family: .unix, proto: .unix)
		try socket?.setBlocking(mode: false)
		
		for i in 0 ..< 10 {
			do {
				try socket?.connect(to: "\(NSTemporaryDirectory())/discord-ipc-\(i)")
				break
			} catch {
				if i == 10 {
					delegate.richPresence(responseTo: error)
				}
				return
			}
		}
		
		do {
			try handshake()
			try startTimers()
		} catch {
			delegate.richPresence(responseTo: error)
		}
	}
	
	open func stop() {
		socket?.close()
		pollTimer?.invalidate()
		pollTimer = nil
		receiveTimer?.invalidate()
		receiveTimer = nil
	}
	
	open func handshake() throws {
		guard let delegate = delegate, let socket = socket else { throw "No delegate or socket" }
		try socket.send(
			delegate.richPresence(responseTo: .handshake)
		)
		if let subscriptions = delegate.subscriptions {
			for subscription in subscriptions {
				try socket.send(
					delegate.richPresence(responseTo: .setSubscription(subscription))
				)
			}
		}
	}
	
	open func startTimers() throws {
		guard let delegate = delegate, let socket = socket else { throw "No delegate or socket" }
		receiveTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
			do {
				try self?.recieve()
			} catch {
				self?.delegate?.richPresence(responseTo: error)
			}
		}
		pollTimer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: true) { [weak self] _ in
			do {
				try self?.updatePresence()
			} catch {
				self?.delegate?.richPresence(responseTo: error)
			}
		}
	}
	
	open func recieve() throws {
		guard let delegate = delegate, let socket = socket else { throw "No delegate or socket" }
		guard
			let response = socket.recieve(),
			let reply = try delegate.richPresence(responseTo: response)
		else { return }
		
		try socket.send(reply)
	}
	
	open func updatePresence() throws {
		guard let delegate = delegate, let socket = socket else { throw "No delegate or socket" }
		try socket.send(
			delegate.richPresence(responseTo: .setActivity)
		)
	}
}
