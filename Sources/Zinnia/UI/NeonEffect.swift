//
//  NeonEffect.swift
//  PlaygroundOTP
//
//  Created by Aspen on 4/5/21.
//

import Foundation
import SwiftUI

struct NeonEffect<S: Shape>: ViewModifier {
	var base: S
	var mask: AnyView?
	var color: Color
	var brightness: Double
	var innerSize: Double
	var middleSize: Double?
	var outerSize: Double?
	var innerBlur: Double?
	var blur: Double

	func body(content: Content) -> some View {
		ZStack {
			content.foregroundColor(color)
			content.blur(radius: CGFloat(blur))
		}
		.overlay(
			base
				.stroke(color, lineWidth: CGFloat(innerSize))
				.brightness(brightness)
				.blur(radius: CGFloat(innerBlur ?? blur))
				.modifier(let: mask) {
					$0.mask($1)
				}
				.allowsHitTesting(false)
		)
		.overlay(
			base
				.stroke(color, lineWidth: CGFloat(middleSize ?? innerSize))
				.brightness(brightness)
				.modifier(let: mask) {
					$0.mask($1)
				}
				.allowsHitTesting(false)
		)
		.background(
			base
				.stroke(color, lineWidth: CGFloat(outerSize ?? (middleSize ?? innerSize)))
				.brightness(brightness)
				.blur(radius: CGFloat(blur))
				.modifier(let: mask) {
					$0.mask($1)
				}
				.allowsHitTesting(false)
		)
		.background(
			base
				.stroke(color, lineWidth: CGFloat(outerSize ?? (middleSize ?? innerSize)))
				.brightness(brightness)
				.blur(radius: CGFloat(blur))
				.opacity(0.2)
				.modifier(let: mask) {
					$0.mask($1)
				}
				.allowsHitTesting(false)
		)
		.compositingGroup()
	}
}
