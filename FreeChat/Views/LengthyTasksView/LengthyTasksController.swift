//
//  LengthyTasksController.swift
//  FileChat
//
//  Created by Bean John on 3/6/2024.
//

import Foundation
import SwiftUI

class LengthyTasksController: ObservableObject {
	
	static let shared: LengthyTasksController = LengthyTasksController()
	
	@Published var tasks: [LengthyTask] = []
	
	var uniqueTasks: [LengthyTask] {
		let uniqueNames: [String] = Array(Set(tasks.map({ $0.name })))
		var result: [LengthyTask] = []
		for uniqueName in uniqueNames {
			for task in tasks {
				if task.name == uniqueName {
					result.append(task)
				}
				break
			}
		}
		return result
	}
	
	public func addTask(name: String, progress: Double) -> LengthyTask {
		let newTask: LengthyTask = LengthyTask(name: name, progress: progress)
		Task {
			await MainActor.run {
				withAnimation(.spring()) {
					LengthyTasksController.shared.tasks.append(newTask)
				}
			}
		}
		return newTask
	}
	
	public func incrementTask(id: UUID, newProgress: Double) {
		Task {
			await MainActor.run {
				withAnimation(.spring()) {
					for index in LengthyTasksController.shared.tasks.indices {
						if LengthyTasksController.shared.tasks[index].id == id {
							LengthyTasksController.shared.tasks[index].progress += newProgress
							break
						}
					}
				}
			}
		}
	}
	
	public func removeTask(id: UUID) {
		Task {
			await MainActor.run {
				withAnimation(.spring()) {
					LengthyTasksController.shared.tasks = LengthyTasksController.shared.tasks.filter({ $0.id != id })
				}
			}
		}
	}
	
}
