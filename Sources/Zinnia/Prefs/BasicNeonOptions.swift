//
//  SwiftUIView.swift
//
//
//  Created by Aspen on 4/8/21.
//

import SwiftUI

struct BasicNeonOptions: View {
	@Binding var mul: Double
	@Binding var color: Color
	@Binding var bg: Color

	var defaultColor = Color.purple
	var defaultBg = Color.white

	@ViewBuilder private func NeonSize() -> some View {
		HStack {
			Text("Neon Size")
			Text(String(format: "%.2fx", mul))
				.font(.system(.caption, design: .monospaced))
			Spacer()
			Slider(value: $mul, in: 0 ... 3)
			Button(action: {
				mul = 1
			}) {
				Image(systemName: "arrow.counterclockwise.circle")
			}.padding(.leading, 5)
		}
	}

	@ViewBuilder private func NeonColor() -> some View {
		HStack {
			ColorPicker("Neon Color", selection: $color)
			Button(action: {
				color = defaultColor
			}) {
				Image(systemName: "arrow.counterclockwise.circle")
			}.padding(.leading, 5)
		}
	}

	@ViewBuilder private func BgColor() -> some View {
		HStack {
			ColorPicker("Background Color", selection: $bg)
			Button(action: {
				bg = defaultBg
			}) {
				Image(systemName: "arrow.counterclockwise.circle")
			}.padding(.leading, 5)
		}
	}

	var body: some View {
		VStack {
			NeonSize()
			NeonColor()
			BgColor()
		}
	}
}
