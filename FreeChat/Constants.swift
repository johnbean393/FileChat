//
//  Constants.swift
//  FileChat
//
//  Created by Peter Sugihara on 9/16/23.
//

import Foundation
import KeyboardShortcuts
import AVFoundation

extension KeyboardShortcuts.Name {
	static let summonFileChat = Self("summonFileChat")
}

let speechSynthesizer: AVSpeechSynthesizer = {
	var synthesizer: AVSpeechSynthesizer = AVSpeechSynthesizer()
	return synthesizer
}()
