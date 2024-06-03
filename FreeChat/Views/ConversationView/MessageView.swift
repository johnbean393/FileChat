//
//  MessageView.swift
//  FreeChat
//
//  Created by Peter Sugihara on 8/4/23.
//

import SwiftUI
import MarkdownUI
import Splash

struct MessageView: View {
	
	@Environment(\.colorScheme) private var colorScheme
	@EnvironmentObject private var conversationManager: ConversationManager
	
	@ObservedObject var m: Message
	let overrideText: String // for streaming replies
	let agentStatus: Agent.Status?
	
	@State var showInfoPopover = false
	@State var isHover = false
	@State var animateDots = false
	
	@State private var showAll: Bool = false
	
	init(_ m: Message, overrideText: String = "", agentStatus: Agent.Status?) {
		self.m = m
		self.overrideText = overrideText
		self.agentStatus = agentStatus
	}
	
	var messageText: String {
		var result: String = (overrideText.isEmpty && m.text != nil ? m.text! : overrideText)
		// make newlines display https://github.com/gonzalezreal/swift-markdown-ui/issues/92
			.replacingOccurrences(of: "\n", with: "  \n", options: .regularExpression)
		if !showAll {
			if let userPrompt = result.split(separator: "  \n  \nHere is some information that may or may not be relevant to my request:").first {
				result = String(userPrompt)
			}
		}
		return result
	}
	
	var infoText: some View {
		
		(agentStatus == .coldProcessing && overrideText.isEmpty
		 ? Text("Warming up...")
		 : Text(m.createdAt ?? Date(), formatter: messageTimestampFormatter))
		.font(.caption)
		
	}
	
	var info: String {
		var parts: [String] = []
		if m.responseStartSeconds > 0 {
			parts.append("Response started in: \(String(format: "%.3f", m.responseStartSeconds)) seconds")
		}
		if m.nPredicted > 0 {
			parts.append("Tokens generated: \(String(format: "%d", m.nPredicted))")
		}
		if m.predictedPerSecond > 0 {
			parts.append("Tokens generated per second: \(String(format: "%.3f", m.predictedPerSecond))")
		}
		if m.modelName != nil, !m.modelName!.isEmpty {
			parts.append("Model: \(m.modelName!)")
		}
		return parts.joined(separator: "\n")
	}
	
	var miniInfo: String {
		var parts: [String] = []
		
		if let ggufCut = try? Regex(".gguf$"),
		   let modelName = m.modelName?.replacing(ggufCut, with: "") {
			parts.append("\(modelName)")
		}
		if m.predictedPerSecond > 0 {
			parts.append("\(String(format: "%.1f", m.predictedPerSecond)) tokens/s")
		}
		
		return parts.joined(separator: ", ")
	}
	
	var menuContent: some View {
		Group {
			if m.responseStartSeconds > 0 {
				Button("Advanced details") {
					self.showInfoPopover.toggle()
				}
			}
			if overrideText == "", m.text != nil, !m.text!.isEmpty {
				CopyButton(text: messageText, buttonText: "Copy message to clipboard")
			}
			Button(showAll ? "Show Less" : "Show All") {
				withAnimation(.spring(duration: 0.8)) {
					showAll.toggle()
				}
			}
		}
	}
	
	var infoLine: some View {
		let processing = !(overrideText.isEmpty && agentStatus != .processing && agentStatus != .coldProcessing)
		let showButtons = isHover && !processing
		
		return HStack(alignment: .center, spacing: 4) {
			infoText
			if processing {
				Button(action: {
					Task {
						await conversationManager.agent.interrupt()
					}
				}, label: {
					Image(systemName: "stop.circle").help("Stop generating text")
				}).buttonStyle(.plain)
			}
			Menu(content: {
				menuContent
			}, label: {
				Image(systemName: "ellipsis.circle").imageScale(.medium)
					.background(.clear)
					.imageScale(.small)
					.padding(.leading, 1)
					.padding(.horizontal, 3)
					.frame(width: 15, height: 15)
					.scaleEffect(CGSize(width: 0.96, height: 0.96))
					.background(.primary.opacity(0.00001)) // needed to be clickable
			})
			.menuStyle(.circle)
			.popover(isPresented: $showInfoPopover) {
				Text(info).padding(12).font(.caption).textSelection(.enabled)
			}
			.opacity(showButtons ? 1 : 0)
			.disabled(!overrideText.isEmpty)
			.padding(0)
			.padding(.vertical, 2)
			if showButtons {
				Text(miniInfo)
					.padding(.leading, 2)
					.font(.caption)
					.textSelection(.enabled)
			}
		}.foregroundColor(.gray)
			.fixedSize(horizontal: false, vertical: true)
			.frame(alignment: .center)
	}
	
	var body: some View {
		HStack(alignment: .top) {
			ZStack(alignment: .bottomTrailing) {
				Image(m.fromId == Message.USER_SPEAKER_ID ? "UserAvatar" : "LlamaAvatar")
					.shadow(color: .secondary.opacity(0.3), radius: 2, x: 0, y: 0.5)
				if agentStatus == .coldProcessing || agentStatus == .processing {
					ZStack {
						Circle()
							.fill(.background)
							.overlay(Circle().stroke(.gray.opacity(0.2), lineWidth: 0.5))
						
						Group {
							Text("•")
								.opacity(animateDots ? 1 : 0)
								.offset(x: 0)
							Text("•")
								.offset(x: 4)
								.opacity(animateDots ? 1 : 0.5)
								.opacity(animateDots ? 1 : 0)
							Text("•")
								.offset(x: 8)
								.opacity(animateDots ? 1 : 0)
								.opacity(animateDots ? 1 : 0)
						}.animation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: animateDots)
							.offset(x: -4, y: -0.5)
							.font(.caption)
						
					}.frame(width: 14, height: 14)
						.task {
							animateDots.toggle()
							animateDots = true
						}
						.onDisappear {
							animateDots = false
						}
						.transition(.opacity)
				}
			}
			.padding(2)
			.padding(.top, 1)
			
			VStack(alignment: .leading, spacing: 1) {
				infoLine
				Group {
					if m.fromId == Message.USER_SPEAKER_ID {
						Text(messageText)
					} else {
						Markdown(messageText)
							.markdownTheme(.freeChat)
							.markdownCodeSyntaxHighlighter(.splash(theme: self.theme))
					}
				}
				.textSelection(.enabled)
				.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
				.transition(.identity)
			}
			.padding(.top, 3)
			.padding(.bottom, 8)
			.padding(.horizontal, 3)
		}
		.padding(.vertical, 3)
		.padding(.horizontal, 8)
		.background(Color(white: 1, opacity: 0.000001)) // makes contextMenu work
		.animation(Animation.easeOut, value: isHover)
		.contextMenu {
			menuContent
		}
		.onHover { hovered in
			isHover = hovered
		}
	}
	
	private var theme: Splash.Theme {
		// NOTE: We are ignoring the Splash theme font
		switch self.colorScheme {
			case ColorScheme.dark:
				return .wwdc17(withFont: .init(size: 16))
			default:
				return .sunset(withFont: .init(size: 16))
		}
	}
}

private let messageTimestampFormatter: DateFormatter = {
	let formatter = DateFormatter()
	formatter.dateStyle = .short
	formatter.timeStyle = .short
	return formatter
}()
