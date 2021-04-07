//
//  SwiftUIView.swift
//
//
//  Created by Aspen on 3/18/21.
//

import LocalAuthentication
import SwiftUI
import UIKit
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

struct UnlockButtonView: View {
	@ObservedObject var globals = ZinniaSharedData.global

	@State private var anim_stroke_size = CGFloat(10.0)
	@State private var anim_faceid_alpha = 1.0
	@State private var flashlight: AVFlashlight? = {
		if AVFlashlight.hasFlashlight() {
			return AVFlashlight()
		} else {
			return nil
		}
	}()

	@State var forceUpdater: Bool = false

	public var unlock: () -> Void
	public var camera: () -> Void

	init(unlock: @escaping () -> Void, camera: @escaping () -> Void) {
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

	var body: some View {
		VStack {
			Text("Tap to unlock")
			HStack {
				Spacer()
				if let flashlight = self.flashlight {
					Circle()
						.frame(width: UIScreen.main.bounds.width * 0.1, height: UIScreen.main.bounds.width * 0.1)
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
								.frame(width: UIScreen.main.bounds.width * 0.1 * 0.5, height: UIScreen.main.bounds.width * 0.1 * 0.5)
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
							forceUpdater.toggle()
						}
					Spacer()
				}
				Circle()
					.frame(width: UIScreen.main.bounds.width * 0.25, height: UIScreen.main.bounds.width * 0.25)
					.foregroundColor(.primary)
					.modifier(
						NeonEffect(
							base: Circle(),
							color: Color.purple,
							brightness: 0.1,
							innerSize: 1.5,
							middleSize: 3,
							outerSize: 5,
							innerBlur: 3,
							blur: 6
						)
					)
					.overlay(
						Image(systemName: get_biometric_icon())
							.foregroundColor(.accentColor)
							.opacity(anim_faceid_alpha)
							.animation(Animation.easeInOut.repeatForever().speed(0.25))
							.font(.system(size: 60))
							.padding()
							.onAppear(perform: {
								self.anim_faceid_alpha = 0.0
							})
							.opacity(globals.unlocked ? 0.0 : 1.0)
							.allowsHitTesting(false)
					)
					.padding()
					.onTapGesture {
						unlock()
					}
				Spacer()
				Circle()
					.frame(width: UIScreen.main.bounds.width * 0.1, height: UIScreen.main.bounds.width * 0.1)
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
						Image(systemName: "camera.fill")
							.resizable()
							.aspectRatio(contentMode: .fit)
							.frame(width: UIScreen.main.bounds.width * 0.1 * 0.5, height: UIScreen.main.bounds.width * 0.1 * 0.5)
							.foregroundColor(.accentColor)
							.padding()
							.allowsHitTesting(false)
					)
					.padding()
					.onTapGesture {
						self.camera()
					}

				Spacer()
			}
		}.padding()
	}
}
