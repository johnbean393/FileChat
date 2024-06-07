//
//  CapsuleButtonStyle.swift
//  FileChat
//
//  Created by Bean John on 6/6/2024.
//

import SwiftUI

struct CapsuleButtonStyle: ButtonStyle {
	
	@State var hovered = false
	
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.font(hovered ? .body.bold() : .body)
			.background(
				RoundedRectangle(cornerSize: CGSize(width: 10, height: 10), style: .continuous)
					.strokeBorder(hovered ? Color.primary.opacity(0) : Color.primary.opacity(0.2), lineWidth: 0.5)
					.foregroundColor(Color.primary)
					.background(hovered ? Color.primary.opacity(0.1) : Color.clear)
			)
			.multilineTextAlignment(.leading) // Center-align multiline text
			.lineLimit(nil) // Allow unlimited lines
			.onHover(perform: { hovering in
				hovered = hovering
			})
			.animation(Animation.easeInOut(duration: 0.16), value: hovered)
			.clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10), style: .continuous))
	}
	
}
