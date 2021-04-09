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
			self.base
				.stroke(self.color, lineWidth: CGFloat(self.innerSize))
				.brightness(self.brightness)
				.blur(radius: CGFloat(self.innerBlur ?? self.blur))
				.modifier(let: self.mask) {
					$0.mask($1)
				}
				.allowsHitTesting(false)
		)
		.overlay(
			self.base
				.stroke(self.color, lineWidth: CGFloat(self.middleSize ?? self.innerSize))
				.brightness(self.brightness)
				.modifier(let: self.mask) {
					$0.mask($1)
				}
				.allowsHitTesting(false)
		)
		.background(
			self.base
				.stroke(self.color, lineWidth: CGFloat(self.outerSize ?? (self.middleSize ?? self.innerSize)))
				.brightness(self.brightness)
				.blur(radius: CGFloat(self.blur))
				.modifier(let: self.mask) {
					$0.mask($1)
				}
				.allowsHitTesting(false)
		)
		.background(
			self.base
				.stroke(self.color, lineWidth: CGFloat(self.outerSize ?? (self.middleSize ?? self.innerSize)))
				.brightness(self.brightness)
				.blur(radius: CGFloat(self.blur))
				.opacity(0.2)
				.modifier(let: self.mask) {
					$0.mask($1)
				}
				.allowsHitTesting(false)
		)
		.compositingGroup()
	}
}
