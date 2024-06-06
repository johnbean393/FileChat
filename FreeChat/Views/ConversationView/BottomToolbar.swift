//
//  BottomToolbar.swift
//  FileChat
//
//  Created by Peter Sugihara on 8/5/23.
//

import SwiftUI
import BezelNotification

struct ChatStyle: TextFieldStyle {
	
	@Environment(\.colorScheme) var colorScheme
	var focused: Bool
	let cornerRadius = 16.0
	var rect: RoundedRectangle {
		RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
	}
	func _body(configuration: TextField<Self._Label>) -> some View {
		configuration
			.textFieldStyle(.plain)
			.frame(maxWidth: .infinity)
			.padding(EdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 6))
			.padding(8)
			.cornerRadius(cornerRadius)
			.background(
				LinearGradient(colors: [Color.textBackground, Color.textBackground.opacity(0.5)], startPoint: .leading, endPoint: .trailing)
			)
			.mask(rect)
			.overlay(rect.stroke(style: StrokeStyle(lineWidth: 1))
				.fill(Color.gray))
			.animation(focused ? .easeIn(duration: 0.2) : .easeOut(duration: 0.0), value: focused)
	}
	
}

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

	var buttonImage: some View {
		let angle: Double = conversationController.panelIsShown ? -90 : 90
		return Image(systemName: "chevron.left.2").rotationEffect(Angle(degrees: angle)).background(Color.clear)
	}
	
	@State private var selectedDir: IndexedDirectory? = nil
	
	var nullState: some View {
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
				.textFieldStyle(ChatStyle(focused: focused))
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
	
	
	var body: some View {
		let messages = conversation.messages
		let showNullState = input == "" && (messages == nil || messages!.count == 0)
		
		VStack(alignment: .trailing) {
			if showNullState {
				nullState.transition(.asymmetric(insertion: .push(from: .trailing), removal: .identity))
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
							.fill(Color.gray)
					}
			}
		}
		.buttonStyle(PlainButtonStyle())
		.padding(.trailing)
	}
	
}

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
