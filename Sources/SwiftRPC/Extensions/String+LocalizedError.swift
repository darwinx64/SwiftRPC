//
//  String+LocalizedError.swift
//  SwiftRPC
//
//  Created by tiramisu on 2025.05.18.
//

import Foundation

extension String: @retroactive Error {}
extension String: @retroactive LocalizedError {
	public var errorDescription: String? { return self }
}
