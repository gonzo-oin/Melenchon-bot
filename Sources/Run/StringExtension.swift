//
//  ArrayExtension.swift
//  Melenchon_bot
//
//  Created by Géraud Vercasson on 04/06/2017.
//
//

import Foundation

extension String {
	func substring(fromPosition: UInt, toPosition: UInt) -> String? {
		guard fromPosition <= toPosition else {
			return nil
		}
		
		guard toPosition < UInt(characters.count) else {
			return nil
		}
		
		let start = index(startIndex, offsetBy: String.IndexDistance(fromPosition))
		let end   = index(startIndex, offsetBy: String.IndexDistance(toPosition) + 1)
		let range = start..<end
		
		return substring(with: range)
	}
}
