//
//  BottomToolbarPanel.swift
//  FileChat
//
//  Created by Bean John on 6/6/2024.
//

import SwiftUI

struct BottomToolbarPanel: View {
	
	@EnvironmentObject var conversationController: ConversationController
	
	@AppStorage("useActions") var useActions: Bool = false
	
	@Binding var selectedDir: IndexedDirectory?
	
	var body: some View {
		GroupBox {
			HSplitView {
				indexSelectionList
					.frame(maxWidth: 550)
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
				.frame(minWidth: 450)
		}
	}
	
	var conversationSettings: some View {
		VStack {
			Text("Chat Settings")
				.bold()
				.font(.title2)
			Divider()
			Form {
				actions
				Section {
					Toggle(isOn: $conversationController.readAloud, label: {
						VStack(alignment: .leading) {
							Text("Read Aloud")
								.font(.title3)
								.bold()
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
	
	var actions: some View {
		Section {
			HStack {
				VStack(alignment: .leading) {
					Text("Actions (Beta)")
						.font(.title3)
						.bold()
					Text("Add or remove actions")
						.font(.caption)
				}
				Spacer()
				Toggle("", isOn: $useActions)
					.toggleStyle(.switch)
				Button("Manage") {
					OpenWindow.actions.open()
				}
				.disabled(!useActions)
			}
		} header: {
			Text("Automation")
		}
	}
	
}
