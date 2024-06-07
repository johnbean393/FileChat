//
//  ActionsView.swift
//  FileChat
//
//  Created by Bean John on 7/6/2024.
//

import SwiftUI

struct ActionsView: View {
	
	@EnvironmentObject private var actionManager: ActionManager
	@State private var selectedAction: Action?
	
	@State private var showAddSheet: Bool = false
	
	var navigationTitle: String {
		return selectedAction == nil ? "Actions" : selectedAction!.shortcut.name
	}
	
    var body: some View {
		NavigationSplitView {
			listView
		} detail: {
			detailView
		}
		.navigationTitle(navigationTitle)
		.sheet(isPresented: $showAddSheet) {
			NewActionSheet(selectedAction: $selectedAction, showAddSheet: $showAddSheet)
		}
    }
	
	var listView: some View {
		VStack(spacing: 0) {
			List(actionManager.values, selection: $selectedAction) { action in
				NavigationLink(action.shortcut.name, value: action)
					.contextMenu {
						Button("Delete") {
							actionManager.removeAction(action)
						}
					}
			}
			VStack(spacing: 0) {
				Divider()
				HStack(spacing: 0) {
					Button("+") {
						actionManager.getAvailableShortcuts()
						showAddSheet = true
					}
					.frame(width: 20, height: 20)
					Divider()
					Button("-") {
						actionManager.removeAction(selectedAction!)
						selectedAction = nil
					}
					.disabled(selectedAction == nil)
					.frame(width: 20, height: 20)
					Divider()
					Spacer()
				}
				.buttonStyle(BorderlessButtonStyle())
				.padding([.leading, .bottom], 3)
			}
			.frame(height: 21)
		}
		.navigationSplitViewColumnWidth(200)
	}
	
	var detailView: some View {
		Group {
			if selectedAction != nil {
				ActionDetailView(selectedAction: $selectedAction)
			} else {
				HStack {
					Text("Select an Action or")
					Button("Add an Action") {
						actionManager.getAvailableShortcuts()
						showAddSheet = true
					}
				}
			}
		}
	}
	
}

#Preview {
    ActionsView()
}
