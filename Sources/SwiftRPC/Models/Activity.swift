//
//  Activity.swift
//  SwiftRPC
//
//  Created by tiramisu on 2025.05.18.
//

import Foundation

public struct Activity: Codable {
	public var name: String?
	public var type: `Type`?
	public var url: URL?
	public var details: String?
	public var state: String?
	public var timestamps: Timestamps?
	public var assets: Assets?
	public var party: Party?
	public var secrets: Secrets?
	public var instance: Bool?
	
	public init(name: String? = nil,
				type: `Type`? = .playing,
				url: URL? = nil,
				details: String? = nil,
				state: String? = nil,
				timestamps: Timestamps? = .init(),
				assets: Assets? = nil,
				party: Party? = nil,
				secrets: Secrets? = nil,
				instance: Bool? = false) {
		self.name = name
		self.type = type
		self.url = url
		self.state = state
		self.details = details
		self.timestamps = timestamps
		self.assets = assets
		self.party = party
		self.secrets = secrets
		self.instance = instance
	}
	
#if os(macOS)
	public static let DidChange = Notification.Name("Activity.DidChange")
#endif
}

// MARK: - Structs
public extension Activity {
	struct Assets: Codable {
		public var largeImage: String? = nil
		public var largeText: String? = nil
		public var smallImage: String? = nil
		public var smallText: String? = nil
		
		public enum CodingKeys: String, CodingKey {
			case largeImage = "large_image"
			case largeText = "large_text"
			case smallImage = "small_image"
			case smallText = "small_text"
		}
		
		public init(largeImage: String? = nil, largeText: String? = nil, smallImage: String? = nil, smallText: String? = nil) {
			self.largeImage = largeImage
			self.largeText = largeText
			self.smallImage = smallImage
			self.smallText = smallText
		}
	}
	
	struct Timestamps: Codable {
		public var start: UInt64? = nil
		public var end: UInt64? = nil
		public init(start: Date? = Date(), end: Date? = nil) {
			if let start {
				self.start = UInt64(start.timeIntervalSince1970)
			}
			if let end {
				self.end = UInt64(end.timeIntervalSince1970)
			}
		}
	}
	
	enum `Type`: Int, Codable {
		case playing = 0
		case streaming = 1
		case listening = 2
		case watching = 3
		case custom = 4
		case competing = 5
	}
	
	struct Secrets: Codable {
		public var join: String? = nil
		public var match: String? = nil
		public var spectate: String? = nil
		public init(join: String? = nil, match: String? = nil, spectate: String? = nil) {
			self.join = join
			self.match = match
			self.spectate = spectate
		}
	}
	
	struct Party: Codable {
		public var id: String?
		public var size: ClosedRange<Int>?
		
		public enum CodingKeys: String, CodingKey {
			case id
			case size
		}
		
		public init(id: String?, size: ClosedRange<Int>?) {
			self.id = id
			self.size = size
		}
		
		public init(from decoder: Decoder) throws {
			let container = try decoder.container(keyedBy: CodingKeys.self)
			id = try container.decodeIfPresent(String.self, forKey: .id)
			
			if let sizeArray = try container.decodeIfPresent([Int].self, forKey: .size) {
				if sizeArray.count == 2 {
					size = sizeArray[0]...sizeArray[1]
				}
			}
		}
		
		public func encode(to encoder: Encoder) throws {
			var container = encoder.container(keyedBy: CodingKeys.self)
			try container.encodeIfPresent(id, forKey: .id)
			
			if let size = size {
				try container.encode([size.lowerBound, size.upperBound], forKey: .size)
			}
		}
	}
}
