//
//  NeonEffect.swift
//  PlaygroundOTP
//
//  Created by Aspen on 4/5/21.
//

import Foundation
import SwiftUI

public struct NeonEffect<S: Shape>: ViewModifier {
	public var base: S
	public var mask: AnyView?
	public var color: Color
	public var brightness: Double
	public var innerSize: Double
	public var middleSize: Double?
	public var outerSize: Double?
	public var innerBlur: Double?
	public var blur: Double

	public func body(content: Content) -> some View {
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
