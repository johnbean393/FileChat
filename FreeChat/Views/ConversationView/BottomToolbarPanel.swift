//
//  BottomToolbarPanel.swift
//  FileChat
//
//  Created by Bean John on 6/6/2024.
//

import SwiftUI

struct BottomToolbarPanel: View {
	
	@EnvironmentObject var conversationController: ConversationController
	
	@Binding var selectedDir: IndexedDirectory?
	
	var body: some View {
		GroupBox {
			HSplitView {
				indexSelectionList
				conversationSettings
			}
			.frame(maxHeight: 250)
			.padding(4)
			.padding(.top, 2)
		}
		.background {
			RoundedRectangle(cornerRadius: 8)
				.fill(Color.textBackground)
		}
		.padding(.horizontal)
	}
	
	var indexSelectionList: some View {
		VStack {
			Text(selectedDir == nil ? "Select a Folder" : "Selected 1 Folder")
				.bold()
				.font(.title2)
			Divider()
			IndexPicker(selectedDir: $selectedDir)
				.padding(.trailing, 4)
		}
	}
	
	var conversationSettings: some View {
		VStack {
			Text("Settings")
				.bold()
				.font(.title2)
			Divider()
			Form {
				Section {
					Toggle(isOn: $conversationController.readAloud, label: {
						VStack(alignment: .leading) {
							Text("Read Aloud")
								.font(.title3)
							Text("Read chatbot reply aloud")
								.font(.caption)
						}
					})
					.toggleStyle(.switch)
				} header: {
					Text("Accessibility")
				}
			}
			
		}
		.formStyle(.grouped)
	}
	
}
