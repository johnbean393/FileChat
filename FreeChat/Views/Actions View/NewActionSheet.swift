//
//  NewActionSheet.swift
//  FileChat
//
//  Created by Bean John on 7/6/2024.
//

import SwiftUI

struct NewActionSheet: View {
	
	@EnvironmentObject private var actionManager: ActionManager
	
	@Binding var selectedAction: Action?
	@Binding var showAddSheet: Bool
	
    var body: some View {
		VStack {
			Text("Select a shortcut")
				.font(.title2)
				.bold()
			Divider()
			GroupBox {
				ScrollView {
					shortcutSelector
				}
				.frame(maxHeight: 350)
			}
		}
		.padding()
		.onAppear {
			actionManager.getAvailableShortcuts()
		}
    }
	
	var shortcutSelector: some View {
		VStack(alignment: .leading) {
			ForEach(actionManager.availableShortcuts) { shortcut in
				Text(shortcut.name)
					.onTapGesture {
						// Add action and select it
						let action: Action = Action(
							shortcut: shortcut
						)
						actionManager.addAction(action)
						selectedAction = action
						// Close sheet
						showAddSheet.toggle()
					}
				Divider()
			}
		}
		.frame(minWidth: 350)
	}
}

//#Preview {
//    NewActionSheet()
//}
