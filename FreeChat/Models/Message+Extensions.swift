//
//  Message+Extensions.swift
//  FreeChat
//
//  Created by Peter Sugihara on 7/31/23.
//

import CoreData
import Foundation
import SimilaritySearchKit

extension Message {
	
	static let USER_SPEAKER_ID = "### User"
	
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
			// Calculate number of search results
			let contextLength: Int = UserDefaults.standard.integer(forKey: "contextLength")
			let searchResultsCount: Int = max(
				Int((contextLength - 10000) / 1000),
				1
			)
			// Initiate search
			let searchResults: [SimilarityIndex.SearchResult] = await IndexStore.shared.similarityIndex!.search(text)
//			print("searchResultsScores:", searchResults.map({ abs(100 - abs($0.score)) }))
			let filteredResults: [SimilarityIndex.SearchResult] =
			Array(
				searchResults
					.sorted(by: { abs(100 - abs($0.score)) <= abs(100 - abs($1.score)) })
					.filter({ abs(100 - abs($0.score)) <= 12.5 })
					.dropLast(searchResults.count - searchResultsCount)
			)
//			print("filteredResultsScores:", filteredResults.map({ abs(100 - abs($0.score)) }))
			// If filtered results is blank
			if filteredResults.isEmpty {
				// Just return text
				record.text = text
				// Send back on main thread
				await MainActor.run {
					do {
						try ctx.save()
					} catch { print(error) }
				}
			} else {
				// Else, continue
				let sourcesText: String = filteredResults.map { "\($0.text)\n \($0.metadata["source"] ?? "")" }.joined(separator: "\n")
				// Process text to add search results
				record.text = """
\(text)

Here is some information that may or may not be relevant to my request:
"\(sourcesText)"
"""
				// Send back on main thread
				await MainActor.run {
					do {
						try ctx.save()
					} catch { print(error) }
				}
			}
		} else {
			// Just return text
			record.text = text
			try ctx.save()
		}
		// Return result
		return record
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
