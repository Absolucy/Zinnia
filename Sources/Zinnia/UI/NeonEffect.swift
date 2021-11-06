//  Copyright (c) 2021 Lucy <lucy@absolucy.moe>
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

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
		)
		.overlay(
			base
				.stroke(color, lineWidth: CGFloat(middleSize ?? innerSize))
				.brightness(brightness)
		)
		.background(
			base
				.stroke(color, lineWidth: CGFloat(outerSize ?? (middleSize ?? innerSize)))
				.brightness(brightness)
				.blur(radius: CGFloat(blur))
		)
		.background(
			base
				.stroke(color, lineWidth: CGFloat(outerSize ?? (middleSize ?? innerSize)))
				.brightness(brightness)
				.blur(radius: CGFloat(blur))
				.opacity(0.2)
		)
		.compositingGroup()
	}
}
