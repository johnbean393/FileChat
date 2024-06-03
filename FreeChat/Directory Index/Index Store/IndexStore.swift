//
//  IndexStore.swift
//  FreeChat
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
	
	static let shared: IndexStore = IndexStore()
	
	var isLoadingIndex: Bool = false
	
	var selectedDirectory: IndexedDirectory? = nil {
		didSet {
			loadSimilarityIndex()
		}
	}
	
	var similarityIndex: SimilarityIndex? = nil
	
	func saveSelectedDirectory() {
		if selectedDirectory != nil {
			for index in self.values.indices {
				if self.values[index].id == selectedDirectory!.id {
					self.values[index] = selectedDirectory!
					break
				}
			}
		}
	}
	
	func loadSimilarityIndex() {
		if selectedDirectory != nil {
			isLoadingIndex = true
			Task {
				await similarityIndex = selectedDirectory!.loadIndex()
				isLoadingIndex = false
				await MainActor.run {
					let notification: BezelNotification = BezelNotification(text: "FreeChat has finished loading your folder", visibleTime: 2)
					notification.show()
				}
			}
		}
	}
	
	func addIndexedDirectory(url: URL) {
		Task {
			var indexedDir: IndexedDirectory = IndexedDirectory(url: url)
			await indexedDir.setup()
			await addToIndexedDir(indexedDir: indexedDir)
		}
	}
	
	private func addToIndexedDir(indexedDir: IndexedDirectory) async {
		await MainActor.run {
			IndexStore.shared.values.append(indexedDir)
		}
	}
	
	func removeIndex(indexedDir: IndexedDirectory) {
		// Remove directory
		do {
			try FileManager.default.removeItem(at: indexedDir.indexUrl)
		} catch {}
		// Remove index
		IndexStore.shared.values = IndexStore.shared.values.filter({ $0 != indexedDir })
	}
	
	func updateIndex() async {
		isLoadingIndex = true
		if selectedDirectory != nil {
			await selectedDirectory!.updateDirectoryIndex()
			saveSelectedDirectory()
		}
		await MainActor.run {
			let notification: BezelNotification = BezelNotification(text: "FreeChat has finished updating the folder's index. It will now be loaded into memory.", visibleTime: 2)
			notification.show()
			loadSimilarityIndex()
		}
		isLoadingIndex = false
	}
	
}
