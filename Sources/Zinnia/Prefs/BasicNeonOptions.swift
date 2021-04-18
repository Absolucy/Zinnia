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

	var body: some View {
		VStack {
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
			HStack {
				ColorPicker("Neon Color", selection: $color)
				Button(action: {
					color = defaultColor
				}) {
					Image(systemName: "arrow.counterclockwise.circle")
				}.padding(.leading, 5)
			}
			HStack {
				ColorPicker("Background Color", selection: $bg)
				Button(action: {
					bg = defaultBg
				}) {
					Image(systemName: "arrow.counterclockwise.circle")
				}.padding(.leading, 5)
			}
		}
	}
}