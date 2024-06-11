//
//  ActionManager.swift
//  FileChat
//
//  Created by Bean John on 7/6/2024.
//

import Foundation
import ExtensionKit
import SimilaritySearchKit
import SQLite

class ActionManager: ValueDataModel<Action> {
	
	required init(appDirName: String = Bundle.main.applicationName ?? Bundle.main.description, datastoreName: String = "actions.json") {
		return
	}
	
	static let shared: ActionManager = ActionManager(datastoreName: "actions")
	
	@Published var availableShortcuts: [Shortcut] = []
	
	/// Add an action
	public func addAction(_ action: Action) {
		Self.shared.values.append(action)
	}
	
	/// Update an existing action
	public func updateAction(_ action: Action) {
		for index in Self.shared.values.indices {
			if Self.shared.values[index].id == action.id {
				Self.shared.values[index] = action
				break
			}
		}
	}
	
	/// Remove a action
	public func removeAction(_ action: Action) {
		Self.shared.values = Self.shared.values.filter({ $0 != action })
	}
	
	/// Get available shortcuts for user selection
	public func getAvailableShortcuts() {
		// Try to access database
		do {
			// Get access to Shortcuts directory
			do {
				let _ = try FileSystemTools.openPanel(
					url: URL(fileURLWithPath: "/Users/\(NSUserName())/Library/Shortcuts"),
					files: false,
					folders: true,
					dialogTitle: "Press \"Open\" to give FileChat permission to view existing shortcuts"
				)
			} catch {  }
			// Define database file path
			let dbUrl: URL = URL(fileURLWithPath: "/Users/\(NSUserName())/Library/Shortcuts/Shortcuts.sqlite")
			// Define table structure
			let database: Connection = try Connection(dbUrl.posixPath())
			let shortcutsTable: Table = Table("ZSHORTCUT")
			let id = Expression<String>("ZWORKFLOWID")
			let name = Expression<String>("ZNAME")
			let subtitle = Expression<String?>("ZWORKFLOWSUBTITLE")
			let lastSynced = Expression<Int?>("ZLASTSYNCEDHASH")
			// Get and save shortcut info
			for shortcut in try database.prepare(shortcutsTable) {
				// If shortcut is not deleted and not a duplicate
				let notCorrupted: Bool = shortcut[subtitle] != nil && shortcut[lastSynced] != nil
				let notDuplicate: Bool = !availableShortcuts.map({ $0.id }).contains(UUID(uuidString: shortcut[id]))
				let notExisting: Bool = !values.map({ $0.shortcut.id }).contains(UUID(uuidString: shortcut[id])) && !values.map({ $0.shortcut.name }).contains(shortcut[name])
				if notCorrupted && notDuplicate && notExisting {
					// Add to list
					Self.shared.availableShortcuts.append(
						Shortcut(
							id: UUID(uuidString: shortcut[id])!,
							name: shortcut[name]
						)
					)
				}
			}
		} catch {
			// If fail, save blank array & output error
			Self.shared.availableShortcuts = []
			print(error)
		}
	}
	
	// Find an action
	public func findActions(text: String) async -> String {
		// Create index
		let similarityIndex: SimilarityIndex = await SimilarityIndex(metric: DotProduct())
		for action in Self.shared.values {
			await similarityIndex.addItem(
				id: action.shortcut.id.uuidString,
				text: action.shortcut.samplePrompt,
				metadata: ["actionId": action.id.uuidString]
			)
		}
		// Search index
		// Max number of search results
		let maxResultsCount: Int = 3
		// Initiate search
		let threshold: Float = 1.3
		let searchResults: [SimilarityIndex.SearchResult] = await similarityIndex.search(text)
		// Calcuate standard deviation
		let expression: NSExpression = NSExpression(forFunction: "stddev:", arguments: [NSExpression(forConstantValue: searchResults.map({ $0.score }))])
		let stdDev: Float = Float("\(expression.expressionValue(with: nil, context: nil) ?? 7)")!
		// Calculate mean
		let mean: Float = Float(searchResults.map({ $0.score }).reduce(0, +)) / Float(searchResults.count)
		// Print debug info
//		print("searchResults:", searchResults.map({ $0.text }))
//		print("searchResultsScores:", searchResults.map({ $0.score }))
//		print("searchResultsDistanceFromStdDev:", searchResults.map({ (abs($0.score - mean) / stdDev) }))
		// Filter results
		let filteredResults: [SimilarityIndex.SearchResult] =
		Array(
			searchResults
				.filter({ (abs($0.score - mean) / stdDev) >= threshold })
				.sorted(by: { (abs($0.score - mean) / stdDev) <= (abs($1.score - mean) / stdDev) })
				.dropLast(
					max(searchResults.filter({ (abs($0.score - mean) / stdDev) >= threshold }).count - maxResultsCount, 0)
				)
		)
//		print("filteredResultsScores:", filteredResults.map({ abs(Float($0.metadata["baseScore"]!)! - abs($0.score)) }))
		// Match search results to actions
		var actions: [Action] = []
		for result in filteredResults {
			let id: UUID = UUID(uuidString: result.id)!
			for action in Self.shared.values {
				if action.shortcut.id == id {
					actions.append(action)
					break
				}
			}
		}
		// Return text
		// If filtered results is blank
		if actions.isEmpty {
			// Just return text
			return text
		} else {
			// Else, continue
//		let actions: [Action] = Self.shared.values
			let sourcesText: String = actions.map { action in
				let paramDescription: String = action.inputDescription.isEmpty ? "Blank Parameter" : action.inputDescription
				return "`\(action.shortcut.name)(\(paramDescription))`"
			}.joined(separator: "\n")
			// Process text to add search results
			return """
\(text)

If I asked you to, you can execute the following commands by making your response "`NAME OF COMMAND(TEXT VALUE OF PARAMETER)`":
\(sourcesText)
If I didn't ask you to execute a command, never even mention a command.
"""
		}
	}
	
}
