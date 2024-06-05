//
//  Extension+URL.swift
//  FileChat
//
//  Created by Bean John on 5/6/2024.
//

import Foundation

extension URL {
	
	public mutating func replaceParentUrl(oldParentUrl: URL, newParentUrl: URL) {
		let oldPosixPath: String = oldParentUrl.posixPath()
		let newPosixPath: String = newParentUrl.posixPath()
		let newPath: String = self
			.posixPath()
			.replacingOccurrences(of: oldPosixPath, with: newPosixPath)
		print("\(oldPosixPath) -> \(newPosixPath)")
		self = URL(fileURLWithPath: newPath)
	}
	
}
