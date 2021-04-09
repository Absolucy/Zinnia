#if !THEOS_SWIFT
	import NomaePreferences
#endif
import SwiftUI
import ZinniaC

#if targetEnvironment(simulator)
	@objc public class AVFlashlight: NSObject {
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
	@Binding public var flashlight: AVFlashlight?
	public var action: () -> Void

	@Preference("flashlightBgColor", identifier: ZinniaPreferences.identifier) var flashlightBgColor = Color.primary
	@Preference("flashlightNeonColor", identifier: ZinniaPreferences.identifier) var flashlightNeonColor = Color.yellow
	@Preference("flashlightNeonMul", identifier: ZinniaPreferences.identifier) var flashlightNeonMul: Double = 1
	@Preference("flashlightIconColor", identifier: ZinniaPreferences.identifier) var flashlightIconColor = Color
		.accentColor

	public init(flashlight: Binding<AVFlashlight?> = .constant(nil), action: @escaping () -> Void) {
		self._flashlight = flashlight
		self.action = action
	}

	public var body: some View {
		Button(action: action, label: {
			Circle()
				.frame(width: UIScreen.main.bounds.width * 0.15, height: UIScreen.main.bounds.width * 0.15)
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
						.frame(width: UIScreen.main.bounds.width * 0.15 * 0.5, height: UIScreen.main.bounds.width * 0.15 * 0.5)
						.foregroundColor(flashlightIconColor)
						.opacity(flashlight?.flashlightLevel ?? 0 > 0 ? 1 : 0.5)
						.padding()
						.allowsHitTesting(false)
				)
		}).padding()
	}
}
