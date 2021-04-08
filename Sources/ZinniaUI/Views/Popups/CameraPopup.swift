//
//  SwiftUIView.swift
//
//
//  Created by Aspen on 4/7/21.
//

import SwiftUI

public struct CameraPopup: View {
	public var camera: () -> Void

	public var body: some View {
		Button(action: camera, label: {
			Circle()
				.frame(width: UIScreen.main.bounds.width * 0.15, height: UIScreen.main.bounds.width * 0.15)
				.foregroundColor(ZinniaPreferences.cameraBgColor)
				.modifier(
					NeonEffect(
						base: Circle(),
						color: ZinniaPreferences.cameraNeonColor,
						brightness: 0.1,
						innerSize: 1.5 * ZinniaPreferences.cameraNeonMul,
						middleSize: 3 * ZinniaPreferences.cameraNeonMul,
						outerSize: 5 * ZinniaPreferences.cameraNeonMul,
						innerBlur: 3,
						blur: 6
					)
				)
				.overlay(
					Image(systemName: "camera.fill")
						.resizable()
						.aspectRatio(contentMode: .fit)
						.frame(width: UIScreen.main.bounds.width * 0.15 * 0.5, height: UIScreen.main.bounds.width * 0.15 * 0.5)
						.foregroundColor(ZinniaPreferences.cameraIconColor)
						.padding()
						.allowsHitTesting(false)
				)
		}).padding()
	}
}
