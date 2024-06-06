//
//  LoadingAnimationView.swift
//  FileChat
//
//  Created by Bean John on 4/6/2024.
//

import SwiftUI

struct LoadingAnimationView: View {
	
	@State private var to: CGFloat = 0
	@State private var rotation: CGFloat = 0
	
	var body: some View {
		ZStack {
			Circle()
				.trim(from: 0, to: to)
				.stroke(style: .init(lineWidth: 5, lineCap: .round))
				.foregroundColor(.secondary)
				.rotationEffect(.degrees(rotation))
				.animation(
					.linear(duration: 3)
					.repeatForever(autoreverses: false),
					value: rotation
				)
				.animation(
					.linear(duration: 3)
					.repeatForever(autoreverses: false),
					value: to
				)
				.onAppear {
					DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
						to = 1.0
						rotation = 360
					}
				}
				.frame(width: 10, height: 10)
		}
	}
}

#Preview {
	LoadingAnimationView()
}
