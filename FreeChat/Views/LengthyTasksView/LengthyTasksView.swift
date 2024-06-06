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
			HStack(spacing: 10) {
				Text(lengthyTasksController.uniqueTasks.last!.name)
					.bold()
					.shadow(radius: 5)
				LoadingAnimationView()
			}
			.padding(7.5)
			.background {
				Capsule()
					.stroke(style: StrokeStyle(lineWidth: 1))
					.fill(Color.gray)
			}
		}
	}
	
}
