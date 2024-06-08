//
//  ActionDetailView.swift
//  FileChat
//
//  Created by Bean John on 7/6/2024.
//

import SwiftUI

struct ActionDetailView: View {
	
	@EnvironmentObject private var actionManager: ActionManager
	
	@Binding var selectedAction: Action?
	@State var action: Action = Action(shortcut: Shortcut(id: UUID(), name: ""))
	@State var inputNeeded: Bool = false
	
	@State private var description: String = ""
	
	@State private var askForInput: Bool = false
	
	var body: some View {
		// Form to fill in shortcut details
		Form {
			Section {
				nameAndSamplePrompt
				toggles
				input
			} header: {
				Text("Configuration")
			}
			Section {
				testing
			} header: {
				Text("Testing")
			}
			Section {
				dangerZone
			} header: {
				Text("Danger Zone")
			}
		}
		.formStyle(.grouped)
		.onChange(of: selectedAction) { _ in
			if selectedAction != nil {
				action = selectedAction!
			}
		}
		.onChange(of: action) { _ in
			// Save on update
			actionManager.updateAction(action)
		}
		.onChange(of: inputNeeded) { _ in
			withAnimation(.linear(duration: 0.3)) {
				action.inputType = inputNeeded ? .textInput : .noInput
			}
		}
		.onAppear {
			action = selectedAction!
			inputNeeded = (action.inputType == .textInput)
		}
		.sheet(isPresented: $askForInput) {
			ActionTestInputView(action: $action, askForInput: $askForInput)
		}
	}
	
	var nameAndSamplePrompt: some View {
		Group {
			Group {
				HStack {
					VStack(alignment: .leading) {
						Text("Name")
							.font(.title3)
							.bold()
						Text("The name of the shortcut")
							.font(.caption)
					}
					Spacer()
					Text(action.shortcut.name)
				}
				HStack {
					VStack(alignment: .leading) {
						Text("Sample Prompt")
							.font(.title3)
							.bold()
						Text("This will show how the user typically prompts for the shortcut")
							.font(.caption)
					}
					Spacer()
					TextField("", text: $action.shortcut.samplePrompt)
						.textFieldStyle(.plain)
				}
			}
			.padding(.horizontal, 5)
		}
	}
	
	var toggles: some View {
		Group {
			Toggle(isOn: $action.active, label: {
				VStack(alignment: .leading) {
					Text("Enable Shortcut")
						.font(.title3)
						.bold()
					Text("Toggle shortcut on or off")
						.font(.caption)
				}
			})
			.toggleStyle(.switch)
			Toggle(isOn: $action.confirmBeforeRunning, label: {
				VStack(alignment: .leading) {
					Text("Confirm Before Running")
						.font(.title3)
						.bold()
					Text("Controls whether the user is consulted before the shortcut is run")
						.font(.caption)
				}
			})
			.toggleStyle(.switch)
		}
	}
	
	var input: some View {
		Group {
			Toggle(isOn: $inputNeeded, label: {
				VStack(alignment: .leading) {
					Text("Shortcut Requires Text Input")
						.font(.title3)
						.bold()
					Text("Controls whether the shortcut will run with text input from FileChat")
						.font(.caption)
				}
			})
			.toggleStyle(.switch)
			if action.inputType == .textInput {
				HStack {
					VStack(alignment: .leading) {
						Text("Input Description")
							.font(.title3)
							.bold()
						Text("A description of the shortcut's input. The LLM uses this description to provide the shortcut with input")
							.font(.caption)
					}
					Spacer()
					TextField("", text: $action.inputDescription)
						.textFieldStyle(.plain)
				}
			}
		}
	}
	
	var testing: some View {
		Group {
			HStack {
				VStack(alignment: .leading) {
					Text("Test")
						.font(.title3)
						.bold()
					Text("Run the action")
						.font(.caption)
				}
				Spacer()
				// Button to test run
				Button {
					// Get input
					if inputNeeded {
						askForInput = true
					} else {
						// Else, run shortcut without params
						do {
							try action.run(input: nil)
						} catch {
							// Send alert
							let alert: NSAlert = NSAlert()
							alert.messageText = "Error: \"\(error)\"?"
							alert.addButton(withTitle: "OK")
							let _ = alert.runModal()
						}
					}
				} label: {
					Label("Test", systemImage: "play.fill")
				}
			}
			HStack {
				VStack(alignment: .leading) {
					Text("Debug")
						.font(.title3)
						.bold()
					Text("Find and automatically fix issues")
						.font(.caption)
				}
				Spacer()
				// Button to debug
				Button {
					do {
						try action.locateShortcut()
					} catch {
						print("Error locating shortcut:", error)
					}
				} label: {
					Label("Debug", systemImage: "mappin")
				}
			}
		}
	}
	
	var dangerZone: some View {
		HStack {
			VStack(alignment: .leading) {
				Text("Delete")
					.font(.title3)
					.bold()
				Text("Deletes the action")
					.font(.caption)
			}
			Spacer()
			// Button to delete action
			Button {
				// Send alert
				let alert: NSAlert = NSAlert()
				alert.messageText = "Are you sure you want to delete this action?"
				alert.addButton(withTitle: "Cancel")
				alert.addButton(withTitle: "OK")
				if alert.runModal() == .alertSecondButtonReturn {
					actionManager.removeAction(action)
					selectedAction = nil
				}
			} label: {
				Label("Delete", systemImage: "trash")
			}
		}
	}
	
}
