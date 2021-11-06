//  Copyright (c) 2021 Lucy <lucy@absolucy.moe>
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

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
			flashlightLevel = arg1
			return true
		}

		@objc func turnPowerOff() {
			flashlightLevel = 0
		}
	}
#endif

struct FlashlightPopup: View {
	@State private var flashlight: AVFlashlight? = {
		if AVFlashlight.hasFlashlight() {
			return AVFlashlight()
		} else {
			return nil
		}
	}()

	@Preference("flashlightBgColor", identifier: ZinniaPreferences.identifier) var flashlightBgColor = Color.primary
	@Preference("flashlightNeonColor", identifier: ZinniaPreferences.identifier) var flashlightNeonColor = Color.yellow
	@Preference("flashlightNeonMul", identifier: ZinniaPreferences.identifier) var flashlightNeonMul: Double = 1
	@Preference("flashlightIconColor", identifier: ZinniaPreferences.identifier) var flashlightIconColor = Color
		.accentColor

	var body: some View {
		Button(action: {
			if let flashlight = self.flashlight {
				if flashlight.flashlightLevel > 0 {
					_ = flashlight.setFlashlightLevel(0, withError: nil)
					flashlight.turnPowerOff()
				} else {
					_ = flashlight.setFlashlightLevel(1, withError: nil)
				}
			}
		}, label: {
			Circle()
				.frame(width: mulByWidth(radiusMul / 2), height: mulByWidth(radiusMul / 2))
				.foregroundColor(flashlightBgColor)
				.modifier(
					NeonEffect(
						base: Circle(),
						color: flashlightNeonColor,
						brightness: 0.1,
						innerSize: 1.5 * flashlightNeonMul,
						middleSize: 3 * flashlightNeonMul,
						outerSize: 5 * flashlightNeonMul,
						innerBlur: 3,
						blur: 6
					)
				)
				.overlay(
					Image(systemName: flashlight?.flashlightLevel ?? 0 > 0 ? "flashlight.on.fill" : "flashlight.off.fill")
						.resizable()
						.aspectRatio(contentMode: .fit)
						.frame(width: mulByWidth(radiusMul / 2) * 0.5, height: mulByWidth(radiusMul / 2) * 0.5)
						.foregroundColor(flashlightIconColor)
						.opacity(flashlight?.flashlightLevel ?? 0 > 0 ? 1 : 0.5)
						.padding()
				)
		}).padding()
	}
}
