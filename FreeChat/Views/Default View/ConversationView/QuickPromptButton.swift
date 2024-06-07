//
//  QuickPromptButton.swift
//  FileChat
//
//  Created by Peter Sugihara on 9/4/23.
//

import SwiftUI

struct QuickPromptButton: View {
	
	/// Struct for quick prompts
	struct QuickPrompt: Identifiable {
		
		/// Conform to identifiable
		let id: UUID = UUID()
		
		/// String containing the title of the prompt
		var title: String
		/// String containing the rest of the prompt
		var rest: String
		
		/// Computed property that returns the full prompt
		var text: String {
			return "\(self.title) \(self.rest)"
		}
		
	}
	
	/// A list of test prompts
	static var quickPrompts = [
		QuickPrompt(
			title: "Write an email",
			rest: "asking a colleague for a quick status update."
		),
		QuickPrompt(
			title: "Write a bullet summary",
			rest: "of the leadup and impact of the French Revolution."
		),
		QuickPrompt(
			title: "Design a DB schema",
			rest: "for an online store."
		),
		QuickPrompt(
			title: "Write a SQL query",
			rest: "to count rows in my Users table."
		),
		QuickPrompt(
			title: "How do you",
			rest: "know when a steak is done?"
		),
		QuickPrompt(
			title: "Write a recipe",
			rest: "for the perfect martini."
		),
		QuickPrompt(
			title: "Write a dad joke",
			rest: "that really hits."
		),
		QuickPrompt(
			title: "Write a Linux 1-liner",
			rest: "to count lines of code in a directory."
		),
		QuickPrompt(
			title: "Write me content",
			rest: "for LinkedIn to maximize engagement. It should be about how this post was written by AI. Keep it brief, concise and smart."
		),
		QuickPrompt(
			title: "Teach me how",
			rest: "to make a pizza in 10 simple steps, with timings and portions."
		),
		QuickPrompt(
			title: "How do I",
			rest: "practice basketball while driving?"
		),
		QuickPrompt(
			title: "Can you tell me",
			rest: "about the gate all around transistor?"
		)
	].shuffled()
	
	@Binding var input: String
	var prompt: QuickPrompt
	
	var body: some View {
		Button(action: {
			input = prompt.text
		}, label: {
			VStack(alignment: .leading) {
				Text(prompt.title).bold().font(.caption2).lineLimit(1)
				Text(prompt.rest).font(.caption2).lineLimit(1).foregroundColor(.secondary)
			}
			.padding(.vertical, 8)
			.padding(.horizontal, 10)
			.frame(maxWidth: .infinity, alignment: .leading)
		})
		.buttonStyle(CapsuleButtonStyle())
		.frame(maxWidth: 300)
	}
	
}
