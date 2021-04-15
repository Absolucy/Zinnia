import LocalAuthentication
#if !THEOS_SWIFT
	import NomaePreferences
#endif
import SwiftUI
import UIKit
import ZinniaC

internal struct UnlockButtonView: View {
	@ObservedObject private var globals = ZinniaSharedData.global
	@State private var anim_faceid_alpha = 1.0
	@State private var selected: Int? = nil
	@State private var flashlight: AVFlashlight? = {
		if AVFlashlight.hasFlashlight() {
			return AVFlashlight()
		} else {
			return nil
		}
	}()

	@State private var autocloseTask: DispatchWorkItem?

	@Preference("unlockBgColor", identifier: ZinniaPreferences.identifier) private var unlockBgColor = Color.primary
	@Preference("unlockNeonMul", identifier: ZinniaPreferences.identifier) private var unlockNeonMul: Double = 1
	@Preference("unlockNeonColor", identifier: ZinniaPreferences.identifier) private var unlockNeonColor = Color.purple
	@Preference("unlockIconColor", identifier: ZinniaPreferences.identifier) private var unlockIconColor = Color
		.accentColor

	private var unlock: () -> Void
	private var camera: () -> Void

	internal init(unlock: @escaping () -> Void, camera: @escaping () -> Void) {
		self.unlock = unlock
		self.camera = camera
	}

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
		self.autocloseTask?.cancel()
		let task = DispatchWorkItem {
			withAnimation(Animation.spring()) {
				globals.menuOpenProgress = 0
			}
			self.selected = nil
			globals.draggingMenuOpen = false
			self.autocloseTask = nil
		}
		DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + timeout, execute: task)
		self.autocloseTask = task
	}

	private func xOffset(_ index: Int) -> CGFloat {
		let menuRadius = mulByWidth(radiusMul)

		let slice = CGFloat(2 * .pi / CGFloat(self.getPopups().count + 1))
		return menuRadius * cos(slice * CGFloat(index))
	}

	private func yOffset(_ index: Int) -> CGFloat {
		let menuRadius = mulByWidth(radiusMul)

		let slice = -CGFloat(2 * .pi / CGFloat(self.getPopups().count + 1))
		return menuRadius * sin(slice * CGFloat(index))
	}

	private func toggleFlashlight() {
		if let flashlight = self.flashlight {
			if flashlight.flashlightLevel > 0 {
				_ = flashlight.setFlashlightLevel(0, withError: nil)
				flashlight.turnPowerOff()
			} else {
				_ = flashlight.setFlashlightLevel(1, withError: nil)
			}
		}
	}

	private func getPopups() -> [(AnyView, () -> Void)] {
		var popups: [(AnyView, () -> Void)] = []
		popups.append((AnyView(CameraPopup(camera: self.camera)), self.camera))
		popups.append((AnyView(LockPopup(unlock: self.unlock)), self.unlock))
		if case .some = self.flashlight {
			popups
				.append((AnyView(FlashlightPopup(flashlight: $flashlight, action: self.toggleFlashlight)), self.toggleFlashlight))
		}
		return popups
	}

	internal var body: some View {
		let popups = self.getPopups()
		if !ZinniaDRM.ticketAuthorized() {
			EmptyView()
		} else {
			HStack {
				Spacer()
				ZStack {
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
								.allowsHitTesting(false)
						)
						.padding()
						.onTapGesture {
							autoClose(2.5)
							globals.draggingMenuOpen = false
							withAnimation {
								globals.menuOpenProgress = globals.menuOpenProgress > 0 ? 0 : 1
							}
						}
						.gesture(
							DragGesture()
								.onChanged { gesture in
									autoClose()
									globals.draggingMenuOpen = true
									let radius = mulByWidth(radiusMul) - mulByWidth(radiusMul / 2)
									let offset = gesture.translation
									withAnimation(Animation.spring()) {
										globals.menuOpenProgress = min(1.0, max(abs(offset.width), abs(offset.height)) / radius)
									}
									var selected: Int?
									for index in 0 ..< popups.count {
										let x = self.xOffset(index)
										let y = self.yOffset(index)
										if abs(gesture.location.x - (gesture.startLocation.x + x)) <= mulByWidth(radiusMul / 2),
										   abs(gesture.location.y - (gesture.startLocation.y + y)) <= mulByWidth(radiusMul / 2)
										{
											selected = index
											break
										}
									}
									self.selected = selected
								}
								.onEnded { _ in
									autocloseTask?.cancel()
									if let selected = self.selected {
										popups[selected].1()
									}
									withAnimation(Animation.spring().delay(1)) {
										globals.menuOpenProgress = 0
									}
									self.selected = nil
									globals.draggingMenuOpen = false
								}
						)
					ForEach(0 ..< popups.count, id: \.self) { index in
						popups[index]
							.0
							.frame(width: mulByWidth(radiusMul / 2), height: mulByWidth(radiusMul / 2))
							.offset(x: self.xOffset(index),
							        y: self.yOffset(index))
							.opacity(globals
								.menuOpenProgress >= 1 ? (globals.draggingMenuOpen ? (self.selected == index ? 1 : 0.5) : 1) :
								Double(globals.menuOpenProgress))
							.scaleEffect(globals.menuOpenProgress)
					}
				}
				Spacer()
			}.padding()
		}
	}
}
