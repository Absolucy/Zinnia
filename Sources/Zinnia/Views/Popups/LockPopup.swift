//
//  SwiftUIView.swift
//
//
//  Created by Aspen on 4/7/21.
//

import SwiftUI

struct LockPopup: View {
	@ObservedObject var globals = ZinniaSharedData.global
	public var unlock: () -> Void

	var body: some View {
		Circle()
			.frame(width: UIScreen.main.bounds.width * 0.15, height: UIScreen.main.bounds.width * 0.15)
			.foregroundColor(.primary)
			.modifier(
				NeonEffect(
					base: Circle(),
					color: self.globals.unlocked ? Color.green : Color.red,
					brightness: 0.1,
					innerSize: 1.5,
					middleSize: 3,
					outerSize: 5,
					innerBlur: 3,
					blur: 6
				)
			)
			.overlay(
				Image(systemName: self.globals.unlocked ? "lock.open" : "lock")
					.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(width: UIScreen.main.bounds.width * 0.15 * 0.5, height: UIScreen.main.bounds.width * 0.15 * 0.5)
					.foregroundColor(.accentColor)
					.padding()
					.allowsHitTesting(false)
			)
			.padding()
			.onTapGesture {
				self.unlock()
			}
	}
}
