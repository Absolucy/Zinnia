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

struct UnlockButtonView: View {
	@ObservedObject var globals = ZinniaSharedData.global

	@State private var anim_stroke_size = CGFloat(10.0)
	@State private var anim_faceid_alpha = 1.0

	@State var forceUpdater: Bool = false
	@State var menuOpenProgress: CGFloat = 0.0

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

	/// Compute the x value for the specific index menu item
	/// - Parameter index: the menuItem index
	/// - Returns: the x offset
	private func xOffset(_ index: Int) -> CGFloat {
		let menuRadius = UIScreen.main.bounds.width * 0.3

		let slice = CGFloat(2 * .pi / CGFloat(self.getPopups().count))
		return menuRadius * cos(slice * CGFloat(index))
	}

	/// Compute the y value for the specific index menu item
	/// - Parameter index: the menuItem index
	/// - Returns: the y offset
	private func yOffset(_ index: Int) -> CGFloat {
		let menuRadius = UIScreen.main.bounds.width * 0.3

		let slice = CGFloat(2 * .pi / CGFloat(self.getPopups().count))
		return menuRadius * sin(slice * CGFloat(index))
	}

	private func getPopups() -> [AnyView] {
		var popups: [AnyView] = []
		popups.append(AnyView(CameraPopup(camera: self.camera)))
		popups.append(AnyView(LockPopup(unlock: self.unlock)))
		popups.append(AnyView(FlashlightPopup()))
		return popups
	}

	var body: some View {
		let popups = self.getPopups()
		HStack {
			Spacer()
			ZStack {
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
						withAnimation {
							self.menuOpenProgress = self.menuOpenProgress > 0 ? 0 : 1
						}
					}
					.gesture(
						DragGesture()
							.onChanged { gesture in
								let radius = (UIScreen.main.bounds.width * 0.3) - (UIScreen.main.bounds.width * 0.15)
								let offset = gesture.translation
								withAnimation(Animation.spring()) {
									self.menuOpenProgress = min(1.0, ((offset.width + offset.height) / 2) / radius)
								}
							}
							.onEnded { _ in
								withAnimation(Animation.spring()) {
									self.menuOpenProgress = self.menuOpenProgress < 0.75 ? 0 : 1
								}
							}
					)
				ForEach(0 ..< popups.count, id: \.self) { index in
					popups[index]
						.frame(width: UIScreen.main.bounds.width * 0.15, height: UIScreen.main.bounds.width * 0.15)
						.offset(x: self.xOffset(index),
						        y: self.yOffset(index))
						.opacity(Double(self.menuOpenProgress))
						.scaleEffect(self.menuOpenProgress)
					// .rotationEffect(self.menuOpen ? Angle(degrees: 0) : Angle(degrees: 45))
				}
			}
			Spacer()
		}.padding()
	}
}
