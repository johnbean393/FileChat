//
//  IndexStore.swift
//  FileChat
//
//  Created by Bean John on 30/5/2024.
//

import Foundation
import ExtensionKit
import SimilaritySearchKit
import BezelNotification

class IndexStore: ValueDataModel<IndexedDirectory> {
	
	required init(appDirName: String = Bundle.main.applicationName ?? Bundle.main.description, datastoreName: String = "\(Bundle.main.applicationName ?? Bundle.main.description)") {
		super.init(appDirName: appDirName, datastoreName: datastoreName)
	}
	
	/// Shared singleton object
	static let shared: IndexStore = IndexStore()
	
	/// Controls whether new messages can be sent
	var isLoadingIndex: Bool = false
	
	/// Stores the currently selected directory
	var selectedDirectory: IndexedDirectory? = nil {
		didSet {
			loadSimilarityIndex()
		}
	}
	
	/// Caches currently selected index, as it takes a significant time to load from disk
	var similarityIndex: SimilarityIndex? = nil
	
	/// Save the selected IndexedDirectory to disk after it is mutated
	private func saveSelectedDirectory() {
		if selectedDirectory != nil {
			for index in self.values.indices {
				if self.values[index].id == selectedDirectory!.id {
					Task {
						await MainActor.run {
							self.values[index] = selectedDirectory!
						}
					}
					break
				}
			}
		}
	}
	
	/// Loads similarity index from disk
	public func loadSimilarityIndex() {
		if selectedDirectory != nil {
			isLoadingIndex = true
			Task {
				await similarityIndex = selectedDirectory!.loadIndex()
				isLoadingIndex = false
				await MainActor.run {
					let notification: BezelNotification = BezelNotification(text: "FileChat has finished loading your folder", visibleTime: 2)
					notification.show()
				}
			}
		}
	}
	
	/// Sets up a new IndexedDirectory
	public func addIndexedDirectory(url: URL) {
		Task {
			var indexedDir: IndexedDirectory = IndexedDirectory(url: url)
			await indexedDir.setup()
			await addToIndexedDir(indexedDir: indexedDir)
		}
	}
	
	/// Adds IndexedDirectory to JSON storage
	private func addToIndexedDir(indexedDir: IndexedDirectory) async {
		await MainActor.run {
			IndexStore.shared.values.append(indexedDir)
		}
	}
	
	/// Purges an index from disk and removes it from the JSON storage
	func removeIndex(indexedDir: IndexedDirectory) {
		// Remove directory
		do {
			try FileManager.default.removeItem(at: indexedDir.indexUrl)
		} catch {}
		// Remove index
		IndexStore.shared.values = IndexStore.shared.values.filter({ $0 != indexedDir })
	}
	
	/// Updates the currently selected index with incremental indexing
	func updateIndex() async {
		isLoadingIndex = true
		if selectedDirectory != nil {
			await MainActor.run {
				// Check file status
				let fileMoved: Bool = !selectedDirectory!.url.fileExists()
				// Reselect directory if needed
				if fileMoved {
					var tempUrl: URL? = nil
					repeat {
						do {
							tempUrl = try FileSystemTools.openPanel(
								url: URL.desktopDirectory,
								files: false,
								folders: true,
								dialogTitle: "The folder was moved. Please reselect it, then click \"Open\""
							)
						} catch {  }
					} while tempUrl == nil
					for index in selectedDirectory!.indexItems.indices {
						// Replace paths
						selectedDirectory!.indexItems[index].url.replaceParentUrl(
							oldParentUrl: selectedDirectory!.url,
							newParentUrl: tempUrl!
						)
					}
					selectedDirectory!.url = tempUrl!
				} else {
					// Select directory for permissions
					var noError: Bool = false
					repeat {
						do {
							let _ = try FileSystemTools.openPanel(
								url: selectedDirectory!.url,
								files: false,
								folders: true,
								dialogTitle: "FileChat needs permissions to access the folder. Select it, then click \"Open\""
							)
							noError = true
						} catch {  }
					} while !noError
				}
				Task {
					await selectedDirectory!.updateDirectoryIndex()
					saveSelectedDirectory()
				}
				let notification: BezelNotification = BezelNotification(text: "FileChat has finished updating the folder's index. It will now be loaded into memory.", visibleTime: 2)
				notification.show()
				loadSimilarityIndex()
			}
		}
		isLoadingIndex = false
	}


}
