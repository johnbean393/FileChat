//
//  IndexedDirectory.swift
//  FileChat
//
//  Created by Bean John on 30/5/2024.
//

import Foundation
import AppKit
import ExtensionKit
import SimilaritySearchKit
import SimilaritySearchKitDistilbert

public struct IndexedDirectory: Codable, Identifiable, Equatable, Hashable {
	
	// Conform to Equatable
	public static func == (lhs: IndexedDirectory, rhs: IndexedDirectory) -> Bool {
		return lhs.id == rhs.id
	}
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
	
	public var id: UUID = UUID()

	/// Location of the original directory
	public var url: URL
	
	/// Url of the directory where indexes are stored
	public var indexUrl: URL {
		return ContainerManager.indexesUrl.appendingPathComponent(id.uuidString)
	}
	
	/// Items whose index is stores in the directory at "indexUrl"
	public var indexItems: [IndexedDirectory.IndexItem] = []
	
	/// Url of all files in the index directory
	private var indexDirFiles: [URL] {
		return try! indexUrl.listDirectory()
	}
	
	/// Url of all directories in the index directory
	private var indexDirDirs: [URL] {
		return try! indexUrl.listDirectory().filter({ $0.hasDirectoryPath })
	}

	/// Used for loading, must cache after initial load to improve performance
	public func loadIndex() async -> SimilarityIndex {
		// Init index
		let similarityIndex: SimilarityIndex = await SimilarityIndex(
			model: DistilbertEmbeddings(),
			metric: DotProduct()
		)
		// Load index items
		let task: LengthyTask = LengthyTasksController.shared.addTask(name: "Loading \"\(url.lastPathComponent)\" Folder", progress: 0.0)
		for indexItem in indexItems {
			await similarityIndex.indexItems += indexItem.getIndexItems(parentDirUrl: indexUrl, taskId: task.id, taskCount: indexItems.count)
		}
		LengthyTasksController.shared.removeTask(id: task.id)
		// Return index
		return similarityIndex
	}
	
	// Update index
	public mutating func updateDirectoryIndex() async {
		// Update for each file
		let files: [URL] = (try? self.url.listDirectory()) ?? []
		let task: LengthyTask = LengthyTasksController.shared.addTask(name: "Loading \"\(url.lastPathComponent)\" Folder Index", progress: 0.0)
		for file in files {
			await self.indexFile(file: file, taskId: task.id, taskCount: indexItems.count)
		}
		// Filter for moved items
		let tempIndexItems: [IndexItem] = indexItems.filter({ $0.wasMoved })
		for index in tempIndexItems.indices {
			tempIndexItems[index].deleteDirectory(parentDirUrl: indexUrl)
		}
		indexItems = indexItems.filter({ !$0.wasMoved })
		LengthyTasksController.shared.removeTask(id: task.id)
	}

	/// Index a file
	public mutating func indexFile(file: URL, taskId: UUID, taskCount: Int) async {
		// Check if new file
		let isNewFile: Bool = !(indexItems.map({ $0.url }).contains(file))
		// If yes, add file to indexedItems
		if isNewFile { addNewFileToIndex(url: file) }
		// Call updateIndex function
		for currIndex in indexItems.indices {
			if indexItems[currIndex].url == file {
				await indexItems[currIndex].updateIndex(parentDirUrl: indexUrl, taskId: taskId, taskCount: taskCount)
				break
			}
		}
	}
	
	/// Add file to index
	private mutating func addNewFileToIndex(url: URL) {
		// Make new IndexItem
		let indexItem: IndexItem = IndexItem(url: url, prevIndexDate: Date.distantPast)
		// Make directory
		indexItem.createDirectory(parentDirUrl: indexUrl)
		// Add to indexItems
		indexItems.append(indexItem)
		// Indicate change
		print("Added new file at \"\(url.posixPath())\" to index.")
	}
	
	/// Initialize directory
	public mutating func setup() async {
		// Make directory
		try! FileManager.default.createDirectory(at: indexUrl, withIntermediateDirectories: true)
		// Index files
		for currFile in (try! url.listDirectory()) {
			addNewFileToIndex(url: currFile)
		}
		let task: LengthyTask = LengthyTasksController.shared.addTask(name: "Setting up \"\(url.lastPathComponent)\" Folder", progress: 0.0)
		for currIndex in indexItems.indices {
			let selfIndexUrl: URL = indexUrl
			await indexItems[currIndex].updateIndex(parentDirUrl: selfIndexUrl, taskId: task.id, taskCount: indexItems.count)
		}
		LengthyTasksController.shared.removeTask(id: task.id)
	}
	
	/// Reindex directory
	public mutating func reindexDirectory() async {
		// Clear indexItems
		indexItems.removeAll()
		// Clear directory
		try! FileManager.default.removeItem(at: indexUrl)
		/// Re-setup
		await setup()
	}
	
	/// Show index directory
	public func showIndexDirectory() {
		NSWorkspace.shared.activateFileViewerSelecting([indexUrl])
	}
}
