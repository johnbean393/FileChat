//
//  ContainerManager.swift
//  FileChat
//
//  Created by Bean John on 30/5/2024.
//

import Foundation

/// Class that contains information about the app's container
class ContainerManager {
	
	/// Url of directory where all files (Chat records, indexes, etc) are stored
	static let containerUrl: URL = URL
		.applicationSupportDirectory
		.appendingPathComponent("FileChat")
	
	/// Url of directory where all indexes are stored
	static let indexesUrl: URL = ContainerManager
		.containerUrl
		.appendingPathComponent("Indexes")
	
	/// Url of directory where all models are stored
	static let modelsUrl: URL = ContainerManager
		.containerUrl
		.appendingPathComponent("Models")
	
	/// Array of all urls in the container
	static var allContainerDirs: [URL] {
		return [
			ContainerManager.containerUrl,
			ContainerManager.indexesUrl,
			ContainerManager.modelsUrl
		]
	}
	
	/// Function that initializes the container
	static func initContainer() {
		// Create container directories
		allContainerDirs.forEach { url in
			try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
		}
	}
	
}
