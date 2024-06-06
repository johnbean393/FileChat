//
//  FileChatApp.swift
//  FileChat
//
//  Created by Peter Sugihara on 7/31/23.
//

import SwiftUI
import KeyboardShortcuts

@main
struct FileChatApp: App {
	
	@NSApplicationDelegateAdaptor(FileChatAppDelegate.self) private var appDelegate
	@Environment(\.openWindow) var openWindow
	@StateObject private var conversationManager = ConversationManager.shared
	@StateObject private var indexStore: IndexStore = IndexStore.shared
	@StateObject private var lengthyTasksController: LengthyTasksController = LengthyTasksController.shared
	@StateObject private var converationController: ConversationController = ConversationController.shared
	
	let persistenceController = PersistenceController.shared
	
	var body: some Scene {
		
		Window(Text("FileChat"), id: "main") {
			ContentView()
				.environment(\.managedObjectContext, persistenceController.container.viewContext)
				.environmentObject(conversationManager)
				.environmentObject(indexStore)
				.environmentObject(lengthyTasksController)
				.environmentObject(converationController)
				.onAppear {
					NSWindow.allowsAutomaticWindowTabbing = false
					let _ = NSApplication.shared.windows.map { $0.tabbingMode = .disallowed }
				}
		}
		.commands {
			CommandMenu("Chat") {
				Button("New Chat") {
					conversationManager.newConversation(viewContext: persistenceController.container.viewContext, openWindow: openWindow)
				}.keyboardShortcut(KeyboardShortcut("N"))
				Button("\(converationController.panelIsShown ? "Hide": "Show") \"Select Folder\" Panel") {
					withAnimation(.spring()) {
						converationController.panelIsShown.toggle()
					}
				}.keyboardShortcut(KeyboardShortcut("P"))
			}
			SidebarCommands()
			CommandGroup(after: .windowList, addition: {
				Button("Conversations") {
					conversationManager.bringConversationToFront(openWindow: openWindow)
				}.keyboardShortcut(KeyboardShortcut("0"))
			})
		}
		
		Settings {
			SettingsView()
				.environment(\.managedObjectContext, persistenceController.container.viewContext)
				.environmentObject(conversationManager)
		}
		.windowResizability(.contentSize)
		
	}
}
