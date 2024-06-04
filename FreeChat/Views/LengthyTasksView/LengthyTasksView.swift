//
//  LengthyTasksView.swift
//  FileChat
//
//  Created by Bean John on 3/6/2024.
//

import Foundation
import SwiftUI

struct LengthyTasksView: View {
	
	@EnvironmentObject private var lengthyTasksController: LengthyTasksController
	
	var body: some View {
		if !lengthyTasksController.uniqueTasks.isEmpty {
			ScrollView {
				VStack(spacing: 0) {
					ForEach(lengthyTasksController.uniqueTasks) { task in
						HStack(spacing: 0) {
							Text(task.name)
								.lineLimit(1)
								.frame(maxWidth: 300)
							LoadingAnimationView()
						}
						.frame(maxWidth: 320)
					}
				}
			}
			.scrollIndicators(.never)
			.frame(maxHeight: 30)
			.padding(.top, 10)
		}
	}
	
}
