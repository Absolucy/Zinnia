//  Copyright (c) 2021 Lucy <lucy@absolucy.moe>
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

import LocalAuthentication
import SwiftUI
import UIKit
import ZinniaC

internal struct UnlockButtonView: View {
	@ObservedObject private var globals = SharedData.instance
	@ObservedObject private var popupController = ZinniaPopupController.global
	@State private var anim_faceid_alpha = 1.0
	@State private var autocloseTask: DispatchWorkItem?

	@Preference("unlockBgColor", identifier: ZinniaPreferences.identifier) private var unlockBgColor = Color.primary
	@Preference("unlockNeonMul", identifier: ZinniaPreferences.identifier) private var unlockNeonMul: Double = 1
	@Preference("unlockNeonColor", identifier: ZinniaPreferences.identifier) private var unlockNeonColor = Color.purple
	@Preference("unlockIconColor", identifier: ZinniaPreferences.identifier) private var unlockIconColor = Color
		.accentColor
	@Preference("unlockPadding", identifier: ZinniaPreferences.identifier) private var unlockPadding: Double = 9
	@Preference("unlockEnabled", identifier: ZinniaPreferences.identifier) var unlockEnabled = true

	private func get_biometric_icon() -> String {
		let authContext = LAContext()
		_ = authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
		switch authContext.biometryType {
		case .touchID:
			return "touchid"
		case .faceID:
			return "faceid"
		default:
			return "lock"
		}
	}

	private func autoClose(_ timeout: Double = 1) {
		autocloseTask?.cancel()
		let task = DispatchWorkItem(qos: .userInteractive) {
			withAnimation(Animation.spring()) {
				globals.menuOpenProgress = 0
			}
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, qos: .userInteractive) {
				globals.menuIsOpen = false
			}
			globals.selected = nil
			globals.draggingMenuOpen = false
			self.autocloseTask = nil
		}
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + timeout, execute: task)
		autocloseTask = task
	}

	internal var body: some View {
		VStack {
			Circle()
				.frame(width: mulByWidth(circleMul), height: mulByWidth(circleMul))
				.foregroundColor(self.unlockBgColor)
				.modifier(
					NeonEffect(
						base: Circle(),
						color: self.unlockNeonColor,
						brightness: 0.1,
						innerSize: 1.5 * self.unlockNeonMul,
						middleSize: 3 * self.unlockNeonMul,
						outerSize: 5 * self.unlockNeonMul,
						innerBlur: 3,
						blur: 6
					)
				)
				.overlay(
					Image(systemName: get_biometric_icon())
						.foregroundColor(self.unlockIconColor)
						.opacity(anim_faceid_alpha)
						.font(.system(size: 60))
						.padding()
						.onAppear(perform: {
							withAnimation(Animation.easeInOut.repeatForever().speed(0.25)) {
								self.anim_faceid_alpha = 0.0
							}
						})
						.opacity(globals.unlocked ? 0.0 : 1.0)
				)
				.padding(.bottom, CGFloat(unlockPadding))
				.onTapGesture {
					autoClose(2.5)
					globals.draggingMenuOpen = false
					globals.menuIsOpen = true
					withAnimation {
						globals.menuOpenProgress = globals.menuOpenProgress > 0 ? 0 : 1
					}
				}
				.gesture(
					DragGesture()
						.onChanged { gesture in
							autoClose()
							globals.draggingMenuOpen = true
							globals.menuIsOpen = true
							let radius = mulByWidth(radiusMul) - mulByWidth(radiusMul / 2)
							let offset = gesture.translation
							withAnimation(Animation.easeInOut) {
								globals.menuOpenProgress = min(1.0, max(abs(offset.width), abs(offset.height)) / radius)
							}
							var selected: Int?
							let angle = abs(Double(atan2(gesture.startLocation.y - gesture.location.y,
							                             gesture.startLocation.x - gesture.location.x) * (180 / .pi)))
							let angle_mul = Double(270 / popupController.popups.count)
							let min_distance = Double(180 / popupController.popups.count)
							for index in 0 ..< popupController.popups.count {
								let this_angle = angle_mul * Double(index)
								if angle >= this_angle - min_distance, angle <= this_angle + min_distance {
									selected = index
								}
							}
							globals.selected = selected
						}
						.onEnded { _ in
							autocloseTask?.cancel()
							if let selected = globals.selected {
								popupController.popups[selected].1()
							}
							withAnimation(Animation.spring().delay(1)) {
								globals.menuOpenProgress = 0
							}
							globals.selected = nil
							globals.draggingMenuOpen = false
						}
				)
				.padding()
		}
	}
}
