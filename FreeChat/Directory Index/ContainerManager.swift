//
//  ContainerManager.swift
//  FreeChat
//
//  Created by Bean John on 30/5/2024.
//

import Foundation

class ContainerManager {
	
	static let containerUrl: URL = URL
		.applicationSupportDirectory
		.appendingPathComponent("FreeChat")
	
	static let indexesUrl: URL = ContainerManager
		.containerUrl
		.appendingPathComponent("Indexes")
	
	static let modelsUrl: URL = ContainerManager
		.containerUrl
		.appendingPathComponent("Models")
	
	static let chatHistoryUrl: URL = ContainerManager
		.containerUrl
		.appendingPathComponent("Chat History")
	
	static var allContainerDirs: [URL] {
		return [
			ContainerManager.containerUrl,
			ContainerManager.indexesUrl,
			ContainerManager.modelsUrl,
			ContainerManager.chatHistoryUrl
		]
	}
	
	static func initContainer() {
		// Create container directories
		allContainerDirs.forEach { url in
			try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
		}
	}
	
}
