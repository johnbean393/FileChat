//
//  LengthyTask.swift
//  FileChat
//
//  Created by Bean John on 3/6/2024.
//

import Foundation

struct LengthyTask: Identifiable, Equatable {
	
	init(name: String, progress: Double) {
		self.name = name
		self.progress = progress
	}
	
	init(name: String, numberOfTasks: Int, progress: Int) {
		self.name = name
		self.progress = Double(progress)/Double(numberOfTasks)
	}
	
	var id: UUID = UUID()
	var name: String
	var progress: Double = 0.0
	
}
