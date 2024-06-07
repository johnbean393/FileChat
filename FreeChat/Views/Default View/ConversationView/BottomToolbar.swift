//
//  BottomToolbar.swift
//  FileChat
//
//  Created by Peter Sugihara on 8/5/23.
//

import SwiftUI
import ExtensionKit
import BezelNotification

struct BlurredView: NSViewRepresentable {
	
	func makeNSView(context: Context) -> some NSVisualEffectView {
		let view = NSVisualEffectView()
		view.material = .headerView
		view.blendingMode = .withinWindow
		
		return view
	}
	
	func updateNSView(_ nsView: NSViewType, context: Context) { }
	
}

struct BottomToolbar: View {
	
	@State var input: String = ""
	
	@EnvironmentObject var conversationManager: ConversationManager
	@EnvironmentObject var conversationController: ConversationController
	@EnvironmentObject var indexStore: IndexStore
	
	var conversation: Conversation { conversationManager.currentConversation }
	
	var onSubmit: (String) -> Void
	@State var showNullState = false
	
	@FocusState private var focused: Bool
	
	@State private var selectedDir: IndexedDirectory? = nil
	
	var body: some View {
		let messages = conversation.messages
		let showNullState = input == "" && (messages == nil || messages!.count == 0)
		
		VStack(alignment: .trailing) {
			if showNullState {
				nilState.transition(.asymmetric(insertion: .push(from: .trailing), removal: .identity))
			}
			if conversationController.panelIsShown {
				BottomToolbarPanel(selectedDir: $selectedDir)
			}
			HStack {
				inputField
				LengthyTasksView()
				togglePanelButton
			}
		}
	}
	
	var buttonImage: some View {
		let angle: Double = conversationController.panelIsShown ? -90 : 90
		return Image(systemName: "chevron.left.2").rotationEffect(Angle(degrees: angle)).background(Color.clear)
	}
	
	var nilState: some View {
		ScrollView(.horizontal, showsIndicators: false) {
			HStack {
				ForEach(QuickPromptButton.quickPrompts) { p in
					QuickPromptButton(input: $input, prompt: p)
				}
			}.padding(.horizontal, 10).padding(.top, 200)
		}.frame(maxWidth: .infinity)
	}
	
	var inputField: some View {
		Group {
			TextField("Message", text: $input, axis: .vertical)
				.onSubmit {
					if CGKeyCode.kVK_Shift.isPressed {
						input += "\n"
					} else if indexStore.isLoadingIndex {
						let notification: BezelNotification = BezelNotification(text: "FileChat is currently loading a folder, please wait before sending a message.", visibleTime: 2)
						notification.show()
					} else if input.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
						onSubmit(input)
						input = ""
					}
				}
				.focused($focused)
				.textFieldStyle(ChatStyle(isFocused: _focused))
				.submitLabel(.send)
				.padding([.vertical, .leading], 10)
				.onAppear {
					self.focused = true
				}
				.onChange(of: conversation) { _ in
					if conversationManager.showConversation() {
						self.focused = true
						QuickPromptButton.quickPrompts.shuffle()
					}
				}
				.onChange(of: selectedDir) { _ in
					IndexStore.shared.selectedDirectory = selectedDir
				}
		}
		
	}
	
	var togglePanelButton: some View {
		Button {
			withAnimation(.spring(duration: 0.5)) {
				conversationController.panelIsShown.toggle()
			}
		} label: {
			HStack(spacing: 3) {
				Image(systemName: "paperclip")
					.background(Color.clear)
				Divider()
					.frame(height: 22.5)
				Image(systemName: "gearshape")
					.background(Color.clear)
				Divider()
					.frame(height: 22.5)
				buttonImage
			}
			.font(.system(size: 16))
			.bold()
			.padding(3.5)
			.background {
				Capsule()
					.fill(Color.blue)
					.background {
						Capsule()
							.stroke(style: StrokeStyle(lineWidth: 3.25))
							.fill(Color.white)
					}
			}
		}
		.buttonStyle(PlainButtonStyle())
		.padding(.trailing)
	}
	
}
