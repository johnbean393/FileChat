//
//  ChatStyle.swift
//  FileChat
//
//  Created by Bean John on 6/6/2024.
//

import SwiftUI

struct ChatStyle: TextFieldStyle {
	
	@Environment(\.colorScheme) var colorScheme
	
	@FocusState var isFocused: Bool
	
	let cornerRadius = 16.0
	var rect: RoundedRectangle {
		RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
	}
	
	func _body(configuration: TextField<Self._Label>) -> some View {
		configuration
			.textFieldStyle(.plain)
			.frame(maxWidth: .infinity)
			.padding(EdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 6))
			.padding(8)
			.cornerRadius(cornerRadius)
			.background(
				LinearGradient(colors: [Color.textBackground, Color.textBackground.opacity(0.5)], startPoint: .leading, endPoint: .trailing)
			)
			.mask(rect)
			.overlay(
				rect
					.stroke(style: StrokeStyle(lineWidth: 1))
					.foregroundStyle(isFocused ? Color.orange : Color.white)
			)
			.animation(isFocused ? .easeIn(duration: 0.2) : .easeOut(duration: 0.0), value: isFocused)
	}
	
}
