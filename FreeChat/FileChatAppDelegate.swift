//
//  FileChatAppDelegate.swift
//  FileChat
//

import SwiftUI

class FileChatAppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
	
	@AppStorage("selectedModelId") private var selectedModelId: String?
	
	func application(_ application: NSApplication, open urls: [URL]) {
		let viewContext = PersistenceController.shared.container.viewContext
		do {
			let req = Model.fetchRequest()
			req.predicate = NSPredicate(format: "name IN %@", urls.map({ $0.lastPathComponent }))
			let existingModels = try viewContext.fetch(req).compactMap({ $0.url })
			
			for url in urls {
				guard !existingModels.contains(url) else { continue }
				let insertedModel = try Model.create(context: viewContext, fileURL: url)
				selectedModelId = insertedModel.id?.uuidString
			}
			
			NotificationCenter.default.post(name: NSNotification.Name("selectedModelDidChange"), object: selectedModelId)
			NotificationCenter.default.post(name: NSNotification.Name("needStartNewConversation"), object: selectedModelId)
		} catch {
			print("Error saving model:", error)
		}
	}
	
	func applicationWillTerminate(_ notification: Notification) {
		Task {
			await ConversationManager.shared.agent.llama.stopServer()
		}
	}
	
}
