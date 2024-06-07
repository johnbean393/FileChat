//
//  LengthyTasksView.swift
//  FileChat
//
//  Created by Bean John on 3/6/2024.
//

import Foundation
import SwiftUI
import Shimmer

struct LengthyTasksView: View {
	
	@EnvironmentObject private var lengthyTasksController: LengthyTasksController
	
	var body: some View {
		if !lengthyTasksController.uniqueTasks.isEmpty {
			HStack(spacing: 10) {
				Text(lengthyTasksController.uniqueTasks.last!.name)
					.bold()
					.shadow(radius: 5)
					.shimmering(bandSize: 0.9)
				LoadingAnimationView()
			}
			.padding(8)
			.background {
				Capsule()
					.stroke(style: StrokeStyle(lineWidth: 1))
					.fill(Color.white)
			}
		}
	}
	
}
