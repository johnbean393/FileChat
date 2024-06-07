//
//  Shortcut.swift
//  FileChat
//
//  Created by Bean John on 7/6/2024.
//

import Foundation

struct Shortcut: Identifiable, Codable, Hashable {
	
	var id: UUID
	var name: String
	var samplePrompt: String = ""
	
}
