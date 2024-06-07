//
//  ActionTestInputView.swift
//  FileChat
//
//  Created by Bean John on 7/6/2024.
//

import SwiftUI

struct ActionTestInputView: View {
	
	@Binding var action: Action
	@Binding var askForInput: Bool
	@State private var testInput: String = ""
	
	var body: some View {
		VStack {
			Text("Enter Test Input")
				.font(.title2)
				.bold()
			Divider()
			TextEditor(text: $testInput)
				.font(.title3)
				.frame(minHeight: 300)
			Divider()
			HStack {
				Spacer()
				Button {
					// Run shortcut with param
					do {
						try action.run(input: testInput)
					} catch {
						// Send alert
						let alert: NSAlert = NSAlert()
						alert.messageText = "Error: \"\(error)\"?"
						alert.addButton(withTitle: "OK")
						let _ = alert.runModal()
					}
					askForInput = false
				} label: {
					Label("Run", systemImage: "play.fill")
				}
				.keyboardShortcut(.defaultAction)
			}
		}
		.frame(minWidth: 350)
		.padding()
	}
	
}

//#Preview {
//    ActionTestInputView()
//}
