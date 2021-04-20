#if !THEOS_SWIFT
	import NomaePreferences
#endif
import SwiftUI
import ZinniaC

struct CameraPopup: View {
	internal var action: () -> Void
	// Camera popup
	@Preference("cameraBgColor", identifier: ZinniaPreferences.identifier) var cameraBgColor = Color.primary
	@Preference("cameraNeonColor", identifier: ZinniaPreferences.identifier) var cameraNeonColor = Color.orange
	@Preference("cameraNeonMul", identifier: ZinniaPreferences.identifier) var cameraNeonMul: Double = 1
	@Preference("cameraIconColor", identifier: ZinniaPreferences.identifier) var cameraIconColor = Color.accentColor

	var body: some View {
		if !ZinniaDRM.ticketAuthorized() {
			EmptyView()
		} else {
			Button(action: action, label: {
				Circle()
					.frame(width: mulByWidth(radiusMul / 2), height: mulByWidth(radiusMul / 2))
					.foregroundColor(cameraBgColor)
					.modifier(
						NeonEffect(
							base: Circle(),
							color: cameraNeonColor,
							brightness: 0.1,
							innerSize: 1.5 * cameraNeonMul,
							middleSize: 3 * cameraNeonMul,
							outerSize: 5 * cameraNeonMul,
							innerBlur: 3,
							blur: 6
						)
					)
					.overlay(
						Image(systemName: "camera.fill")
							.resizable()
							.aspectRatio(contentMode: .fit)
							.frame(width: mulByWidth(radiusMul / 2) * 0.5, height: mulByWidth(radiusMul / 2) * 0.5)
							.foregroundColor(cameraIconColor)
							.padding()
					)
			}).padding()
		}
	}
}
