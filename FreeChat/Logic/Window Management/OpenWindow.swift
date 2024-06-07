//
//  OpenWindow.swift
//  FileChat
//
//  Created by Bean John on 7/6/2024.
//

import Foundation
import AppKit
import ExtensionKit

enum OpenWindow: String, CaseIterable, Identifiable {
	
	// All views that can be opened
	case defaultView = "defaultView"
	case actions = "actions"
	
	var id: String { self.rawValue }
	
	func open() {
		Task {
			await MainActor.run { ()
				if !NSApplication.shared.windows.map({ $0.title.camelCased }).contains(self.rawValue.replacingOccurrences(of: "defaultView", with: "fileChat")) {
					if let url = URL(string: "fileChat://\(self.rawValue)") {
						print("Opening... ", url.absoluteString)
						NSWorkspace.shared.open(url)
					}
				}
			}
		}
	}
	
	func close() {
		// Close window
		for currWindow in NSApplication.shared.windows {
			if currWindow.title.camelCased == self.rawValue {
				currWindow.close()
			}
		}
	}
	
}
