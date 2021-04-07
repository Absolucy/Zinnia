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

struct FlashlightPopup: View {
	@State private var flashlight: AVFlashlight? = {
		if AVFlashlight.hasFlashlight() {
			return AVFlashlight()
		} else {
			return nil
		}
	}()

	var body: some View {
		if let flashlight = self.flashlight {
			Circle()
				.frame(width: UIScreen.main.bounds.width * 0.15, height: UIScreen.main.bounds.width * 0.15)
				.foregroundColor(.primary)
				.modifier(
					NeonEffect(
						base: Circle(),
						color: Color.orange,
						brightness: 0.1,
						innerSize: 1.5,
						middleSize: 3,
						outerSize: 5,
						innerBlur: 3,
						blur: 6
					)
				)
				.overlay(
					Image(systemName: flashlight.flashlightLevel > 0 ? "flashlight.on.fill" : "flashlight.off.fill")
						.resizable()
						.aspectRatio(contentMode: .fit)
						.frame(width: UIScreen.main.bounds.width * 0.15 * 0.5, height: UIScreen.main.bounds.width * 0.15 * 0.5)
						.foregroundColor(.accentColor)
						.opacity(flashlight.flashlightLevel > 0 ? 1 : 0.5)
						.padding()
						.allowsHitTesting(false)
				)
				.padding()
				.onTapGesture {
					if flashlight.flashlightLevel > 0 {
						flashlight.setFlashlightLevel(0, withError: nil)
						flashlight.turnPowerOff()
					} else {
						flashlight.setFlashlightLevel(1, withError: nil)
					}
				}
		} else {
			EmptyView()
		}
	}
}
