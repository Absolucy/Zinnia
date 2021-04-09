import LocalAuthentication
#if !THEOS_SWIFT
	import NomaePreferences
#endif
import SwiftUI
import UIKit
import ZinniaC

public struct UnlockButtonView: View {
	@ObservedObject var globals = ZinniaSharedData.global
	@State var anim_faceid_alpha = 1.0
	@State var selected: Int? = nil
	@State var menuOpenProgress: CGFloat = 0.0
	@State var draggingMenuOpen = false
	@State private var flashlight: AVFlashlight? = {
		if AVFlashlight.hasFlashlight() {
			return AVFlashlight()
		} else {
			return nil
		}
	}()

	@Preference("unlockBgColor", identifier: ZinniaPreferences.identifier) var unlockBgColor = Color.primary
	@Preference("unlockNeonMul", identifier: ZinniaPreferences.identifier) var unlockNeonMul: Double = 1
	@Preference("unlockNeonColor", identifier: ZinniaPreferences.identifier) var unlockNeonColor = Color.purple
	@Preference("unlockIconColor", identifier: ZinniaPreferences.identifier) var unlockIconColor = Color.accentColor

	public var unlock: () -> Void
	public var camera: () -> Void

	public init(unlock: @escaping () -> Void, camera: @escaping () -> Void) {
		self.unlock = unlock
		self.camera = camera
	}

	func get_biometric_icon() -> String {
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

	private func xOffset(_ index: Int) -> CGFloat {
		let menuRadius = UIScreen.main.bounds.width * 0.3

		let slice = CGFloat(2 * .pi / CGFloat(self.getPopups().count + 1))
		return menuRadius * cos(slice * CGFloat(index))
	}

	private func yOffset(_ index: Int) -> CGFloat {
		let menuRadius = UIScreen.main.bounds.width * 0.3

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

	public var body: some View {
		let popups = self.getPopups()
		HStack {
			Spacer()
			ZStack {
				Circle()
					.frame(width: UIScreen.main.bounds.width * 0.25, height: UIScreen.main.bounds.width * 0.25)
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
						self.draggingMenuOpen = false
						withAnimation {
							self.menuOpenProgress = self.menuOpenProgress > 0 ? 0 : 1
						}
					}
					.gesture(
						DragGesture()
							.onChanged { gesture in
								self.draggingMenuOpen = true
								let radius = (UIScreen.main.bounds.width * 0.3) - (UIScreen.main.bounds.width * 0.15)
								let offset = gesture.translation
								withAnimation(Animation.spring()) {
									self.menuOpenProgress = min(1.0, max(abs(offset.width), abs(offset.height)) / radius)
								}
								var selected: Int?
								for index in 0 ..< popups.count {
									let x = self.xOffset(index)
									let y = self.yOffset(index)
									if abs(gesture.location.x - (gesture.startLocation.x + x)) <= (UIScreen.main.bounds.width * 0.15),
									   abs(gesture.location.y - (gesture.startLocation.y + y)) <= (UIScreen.main.bounds.width * 0.15)
									{
										selected = index
										break
									}
								}
								self.selected = selected
							}
							.onEnded { _ in
								if let selected = self.selected {
									popups[selected].1()
								}
								withAnimation(Animation.spring().delay(1)) {
									self.menuOpenProgress = 0
								}
								self.selected = nil
								self.draggingMenuOpen = false
							}
					)
				ForEach(0 ..< popups.count, id: \.self) { index in
					popups[index]
						.0
						.frame(width: UIScreen.main.bounds.width * 0.15, height: UIScreen.main.bounds.width * 0.15)
						.offset(x: self.xOffset(index),
						        y: self.yOffset(index))
						.opacity(self
							.menuOpenProgress >= 1 ? (draggingMenuOpen ? (self.selected == index ? 1 : 0.5) : 1) :
							Double(self.menuOpenProgress))
						.scaleEffect(self.menuOpenProgress)
				}
			}
			Spacer()
		}.padding()
	}
}
