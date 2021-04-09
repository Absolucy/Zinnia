import NomaePreferences
import SwiftUI

public struct CameraPopup: View {
	public var camera: () -> Void

	// Camera popup
	@Preference("cameraBgColor", identifier: ZinniaPreferences.identifier) var cameraBgColor = Color.primary
	@Preference("cameraNeonColor", identifier: ZinniaPreferences.identifier) var cameraNeonColor = Color.orange
	@Preference("cameraNeonMul", identifier: ZinniaPreferences.identifier) var cameraNeonMul: Double = 1
	@Preference("cameraIconColor", identifier: ZinniaPreferences.identifier) var cameraIconColor = Color.accentColor

	public init(camera: @escaping () -> Void) {
		self.camera = camera
	}

	public var body: some View {
		Button(action: camera, label: {
			Circle()
				.frame(width: UIScreen.main.bounds.width * 0.15, height: UIScreen.main.bounds.width * 0.15)
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
						.frame(width: UIScreen.main.bounds.width * 0.15 * 0.5, height: UIScreen.main.bounds.width * 0.15 * 0.5)
						.foregroundColor(cameraIconColor)
						.padding()
						.allowsHitTesting(false)
				)
		}).padding()
	}
}
