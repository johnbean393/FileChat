//
//  Message+Extensions.swift
//  FileChat
//
//  Created by Peter Sugihara on 7/31/23.
//

import CoreData
import Foundation
import SimilaritySearchKit

extension Message {
	
	static let USER_SPEAKER_ID = "`## User"
	
	static func create(
		text: String,
		fromId: String,
		conversation: Conversation,
		systemPrompt: String,
		inContext ctx: NSManagedObjectContext
	) async throws -> Self {
		let record = self.init(context: ctx)
		record.conversation = conversation
		record.createdAt = Date()
		record.systemPrompt = systemPrompt
		conversation.lastMessageAt = record.createdAt
		record.fromId = fromId
		
		// If SimilarityIndex is loaded
		if IndexStore.shared.similarityIndex != nil {
			// Add info & actions to prompt
			var finalPrompt: String = await IndexStore.shared.search(text: text)
			// Add actions
			if UserDefaults.standard.bool(forKey: "useActions") {
				finalPrompt = await ActionManager.shared.findActions(
					text: finalPrompt
				)
			}
			// Send back on main thread
			record.text = finalPrompt
			await MainActor.run {
				do {
					try ctx.save()
				} catch { print(error) }
			}
			// Return result
			return record
		} else {
			// Add actions to prompt
			var finalPrompt: String = text
			if UserDefaults.standard.bool(forKey: "useActions") {
				finalPrompt = await ActionManager.shared.findActions(
					text: finalPrompt
				)
			}
			// Send back on main thread
			record.text = finalPrompt
			await MainActor.run {
				do {
					try ctx.save()
				} catch { print(error) }
			}
			// Return result
			return record
		}
	}
	
	public override func willSave() {
		super.willSave()
		
		if !isDeleted, changedValues()["updatedAt"] == nil {
			self.setValue(Date(), forKey: "updatedAt")
		}
		
		if !isDeleted, createdAt == nil {
			self.setValue(Date(), forKey: "createdAt")
		}
	}
	
}
