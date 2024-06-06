//
//  ConversationController.swift
//  FileChat
//
//  Created by Bean John on 6/6/2024.
//

import Foundation
import SwiftUI
import Speech
import AVFoundation

class ConversationController: ObservableObject {
	
	/// Shared singleton object
	static let shared: ConversationController = ConversationController()
	
	/// Controls whether folder selecting panel is shown
	@Published var panelIsShown: Bool = false
	
	/// Controls whether the LLM reads its reply aloud
	@AppStorage("readAloud") var readAloud: Bool = false {
		didSet {
			if !readAloud {
				let boundary: AVSpeechBoundary = .word
				speechSynthesizer.stopSpeaking(at: boundary)
			}
		}
	}
	
}
