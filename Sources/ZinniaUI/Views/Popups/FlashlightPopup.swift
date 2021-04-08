//
//  SwiftUIView.swift
//
//
//  Created by Aspen on 4/7/21.
//

import SwiftUI
import ZinniaC

#if targetEnvironment(simulator)
	@objc class AVFlashlight: NSObject {
		@objc var flashlightLevel: Float = 0

		@objc static func hasFlashlight() -> Bool {
			true
		}

		@objc func setFlashlightLevel(_ arg1: Float, withError _: Any?) -> Bool {
			print("dummy flashlight set to \(arg1) power")
			self.flashlightLevel = arg1
			return true
		}

		@objc func turnPowerOff() {
			self.flashlightLevel = 0
		}
	}
#endif

public struct FlashlightPopup: View {
	@Binding var flashlight: AVFlashlight?
	var action: () -> Void

	public var body: some View {
		Button(action: action, label: {
			Circle()
				.frame(width: UIScreen.main.bounds.width * 0.15, height: UIScreen.main.bounds.width * 0.15)
				.foregroundColor(ZinniaPreferences.flashlightBgColor)
				.modifier(
					NeonEffect(
						base: Circle(),
						color: ZinniaPreferences.flashlightNeonColor,
						brightness: 0.1,
						innerSize: 1.5 * ZinniaPreferences.flashlightNeonMul,
						middleSize: 3 * ZinniaPreferences.flashlightNeonMul,
						outerSize: 5 * ZinniaPreferences.flashlightNeonMul,
						innerBlur: 3,
						blur: 6
					)
				)
				.overlay(
					Image(systemName: flashlight!.flashlightLevel > 0 ? "flashlight.on.fill" : "flashlight.off.fill")
						.resizable()
						.aspectRatio(contentMode: .fit)
						.frame(width: UIScreen.main.bounds.width * 0.15 * 0.5, height: UIScreen.main.bounds.width * 0.15 * 0.5)
						.foregroundColor(ZinniaPreferences.flashlightIconColor)
						.opacity(flashlight!.flashlightLevel > 0 ? 1 : 0.5)
						.padding()
						.allowsHitTesting(false)
				)
		}).padding()
	}
}
