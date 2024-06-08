//
//  Action.swift
//  FileChat
//
//  Created by Bean John on 7/6/2024.
//

import Foundation
import AppKit
import ExtensionKit
import SQLite

struct Action: Identifiable, Codable, Equatable, Hashable {
	
	var id: UUID = UUID()
	
	var shortcut: Shortcut
	
	var active: Bool = true
	var confirmBeforeRunning: Bool = false
	
	var inputType: InputType = .noInput
	var inputDescription: String = ""
	
	public func run(input: String?) throws {
		// Get url
		let url: URL = try generateUrl(input: input)
		// Confirm with user if needed
		if confirmBeforeRunning {
			Task {
				await MainActor.run {
					// Send alert
					let alert: NSAlert = NSAlert()
					alert.messageText = "Are you sure you want to run the shortcut \"\(self.shortcut.name)\"?"
					alert.addButton(withTitle: "Cancel")
					alert.addButton(withTitle: "Yes")
					if alert.runModal() != .alertFirstButtonReturn {
						let _ = NSWorkspace.shared.open(url)
					}
				}
			}
		} else {
			// Else, or continue, open url
			let _ = NSWorkspace.shared.open(url)
		}
	}
	
	private func generateUrl(input: String?) throws -> URL {
		// Make URL
		var url: URL = URL(string: "shortcuts://run-shortcut")!
		url = url.appending(
			queryItems: [
				URLQueryItem(name: "name", value: shortcut.name)
			]
		)
		// If input needed
		if inputType != .noInput {
			// Check input
			if let input = input  {
				url = url.appending(
					queryItems: [
						URLQueryItem(name: "input", value: "text"),
						URLQueryItem(name: "text", value: input)
					]
				)
			} else {
				throw ActionRunError.inputError
			}
		}
		return url
	}
	
	/// Find shortcut if name changed
	public mutating func locateShortcut() throws {
		// Try to access database
		// Get access to Shortcuts directory
		do {
			let _ = try FileSystemTools.openPanel(
				url: URL(fileURLWithPath: "/Users/\(NSUserName())/Library/Shortcuts"),
				files: false,
				folders: true,
				dialogTitle: "The shortcut could not be found. Press \"Open\" to give FileChat permission to view existing shortcuts"
			)
		} catch {  }
		// Define database file path
		let dbUrl: URL = URL(fileURLWithPath: "/Users/\(NSUserName())/Library/Shortcuts/Shortcuts.sqlite")
		// Define table structure
		let database: Connection = try Connection(dbUrl.posixPath())
		let shortcutsTable: Table = Table("ZSHORTCUT")
		let id = Expression<String>("ZWORKFLOWID")
		let name = Expression<String>("ZNAME")
		let description = Expression<String?>("ZACTIONSDESCRIPTION")
		let subtitle = Expression<String?>("ZWORKFLOWSUBTITLE")
		let lastSynced = Expression<Int?>("ZLASTSYNCEDHASH")
		// Get and save shortcut info
		for shortcut in try database.prepare(shortcutsTable) {
			// If shortcut is not deleted
			if shortcut[subtitle] != nil && shortcut[lastSynced] != nil {
				// If shortcuts match
				if shortcut[id] == self.shortcut.id.uuidString {
					// If there was an issue
					if self.shortcut.name != shortcut[name] {
						// Fix it
						self.shortcut.name = shortcut[name]
						// Show issue fixed
						let alert: NSAlert = NSAlert()
						alert.messageText = "You renamed your shortcut, which broke the link! A link has now been reestablished."
						alert.addButton(withTitle: "OK")
						let _ = alert.runModal()
						return
					} else {
						// Show issue fixed
						let alert: NSAlert = NSAlert()
						alert.messageText = "No issues detected."
						alert.addButton(withTitle: "OK")
						let _ = alert.runModal()
						return
					}
				}
			}
		}
		// Show issue not fixed if shortcut was never found
		let alert: NSAlert = NSAlert()
		alert.messageText = "The shortcut could not be located."
		alert.addButton(withTitle: "OK")
		let _ = alert.runModal()
	}
	
	enum InputType: Codable, CaseIterable {
		case noInput
		case textInput
	}
	
	enum ActionRunError: Error {
		case inputError
	}
	
}
