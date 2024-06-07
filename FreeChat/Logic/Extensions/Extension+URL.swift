//
//  Extension+URL.swift
//  FileChat
//
//  Created by Bean John on 5/6/2024.
//

import Foundation
import ExtensionKit

extension URL {
	
	/// Mutating function that, if appropriate, replaces an ancestor of a url
	public mutating func replaceParentUrl(oldParentUrl: URL, newParentUrl: URL) {
		let oldPosixPath: String = oldParentUrl.posixPath()
		let newPosixPath: String = newParentUrl.posixPath()
		let newPath: String = self
			.posixPath()
			.replacingOccurrences(of: oldPosixPath, with: newPosixPath)
		self = URL(fileURLWithPath: newPath)
	}
	
}
