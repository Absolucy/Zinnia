//  Copyright (c) 2021 Lucy <lucy@absolucy.moe>
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI

struct PopupPrefs: View {
	// Camera popup
	@Preference("cameraBgColor", identifier: ZinniaPreferences.identifier) var cameraBgColor = Color.white
	@Preference("cameraNeonColor", identifier: ZinniaPreferences.identifier) var cameraNeonColor = Color
		.orange
	@Preference("cameraNeonMul", identifier: ZinniaPreferences.identifier) var cameraNeonMul: Double = 1
	@Preference("cameraIconColor", identifier: ZinniaPreferences.identifier) var cameraIconColor = Color
		.accentColor

	// Flashlight popup
	@Preference("flashlightBgColor", identifier: ZinniaPreferences.identifier) var flashlightBgColor = Color
		.white
	@Preference("flashlightNeonColor",
	            identifier: ZinniaPreferences.identifier) var flashlightNeonColor = Color.yellow
	@Preference("flashlightNeonMul",
	            identifier: ZinniaPreferences.identifier) var flashlightNeonMul: Double = 1
	@Preference("flashlightIconColor",
	            identifier: ZinniaPreferences.identifier) var flashlightIconColor = Color.accentColor

	// Unlock popup
	@Preference("lockBgColorUnlocked",
	            identifier: ZinniaPreferences.identifier) var lockBgColorUnlocked = Color.white
	@Preference("lockBgColorLocked", identifier: ZinniaPreferences.identifier) var lockBgColorLocked = Color
		.white
	@Preference(
		"lockNeonMulUnlocked",
		identifier: ZinniaPreferences.identifier
	) var lockNeonMulUnlocked: Double = 1
	@Preference("lockNeonMulLocked",
	            identifier: ZinniaPreferences.identifier) var lockNeonMulLocked: Double = 1
	@Preference("lockNeonColorUnlocked",
	            identifier: ZinniaPreferences.identifier) var lockNeonColorUnlocked = Color.green
	@Preference("lockNeonColorLocked",
	            identifier: ZinniaPreferences.identifier) var lockNeonColorLocked = Color.red
	@Preference("lockIconColorUnlocked",
	            identifier: ZinniaPreferences.identifier) var lockIconColorUnlocked = Color
		.accentColor
	@Preference("lockIconColorLocked",
	            identifier: ZinniaPreferences.identifier) var lockIconColorLocked = Color.accentColor

	@State private var popup = 0
	@State private var resetCamera = false
	@State private var resetLight = false
	@State private var resetLockUnlocked = false
	@State private var resetLockLocked = false

	@ViewBuilder private func CameraPreferences() -> some View {
		VStack {
			HStack {
				Spacer()
				CameraPopup(action: {})
					.padding()
					.border(Color.secondary)
				Spacer()
			}
			.padding(.trailing, 10)
			.padding(.vertical, 5)
			BasicNeonOptions(
				mul: $cameraNeonMul,
				color: $cameraNeonColor,
				bg: $cameraBgColor,
				defaultColor: Color.orange,
				defaultBg: Color.white
			).padding(.vertical, 5)
			HStack {
				ColorPicker("Icon Color", selection: $cameraIconColor)
				Button(action: {
					cameraIconColor = Color.accentColor
				}) {
					Image(systemName: "arrow.counterclockwise.circle")
				}.padding(.leading, 5)
			}.padding(.vertical, 5)
			HStack {
				Spacer()
				Button("Reset") {
					self.resetCamera = true
				}
				.alert(isPresented: $resetCamera) {
					Alert(
						title: Text("Are you sure?"),
						message: Text("This will reset all preferences for this view back to the default!"),
						primaryButton: .destructive(Text("Reset")) {
							withAnimation(.spring()) {
								self.cameraNeonColor = Color.orange
								self.cameraNeonMul = 1
								self.cameraBgColor = Color.white
							}
						},
						secondaryButton: .cancel()
					)
				}
				Spacer()
			}.padding(.vertical, 5)
		}
	}

	@ViewBuilder private func FlashlightPreferences() -> some View {
		VStack {
			HStack {
				Spacer()
				FlashlightPopup()
					.padding()
					.border(Color.secondary)
				Spacer()
			}.padding(.trailing, 10).padding(.vertical, 5)
			BasicNeonOptions(
				mul: $flashlightNeonMul,
				color: $flashlightNeonColor,
				bg: $flashlightBgColor,
				defaultColor: Color.yellow
			).padding(.vertical, 5)
			HStack {
				ColorPicker("Icon Color", selection: $flashlightIconColor)
				Button(action: {
					flashlightIconColor = Color.accentColor
				}) {
					Image(systemName: "arrow.counterclockwise.circle")
				}.padding(.leading, 5)
			}.padding(.vertical, 5)
			HStack {
				Spacer()
				Button("Reset") {
					self.resetLight = true
				}
				.alert(isPresented: $resetLight) {
					Alert(
						title: Text("Are you sure?"),
						message: Text("This will reset all preferences for this view back to the default!"),
						primaryButton: .destructive(Text("Reset")) {
							withAnimation(.spring()) {
								self.flashlightNeonColor = Color.yellow
								self.flashlightNeonMul = 1
								self.flashlightBgColor = Color.white
								self.flashlightIconColor = Color.accentColor
							}
						},
						secondaryButton: .cancel()
					)
				}
				Spacer()
			}.padding(.vertical, 5)
		}
	}

	@ViewBuilder private func LockPreferences() -> some View {
		VStack {
			HStack {
				Spacer()
				HStack {
					LockPopup(action: {}, globals: SharedData(unlocked: true))
						.padding(.trailing, 10)
					LockPopup(action: {}, globals: SharedData(unlocked: false))
						.padding(.leading, 10)
				}
				.padding()
				.border(Color.secondary)
				Spacer()
			}.padding(.trailing, 10).padding(.vertical, 5)
			Section(header: Text("Unlocked")) {
				BasicNeonOptions(
					mul: $lockNeonMulUnlocked,
					color: $lockNeonColorUnlocked,
					bg: $lockBgColorUnlocked,
					defaultColor: Color.green
				).padding(.vertical, 5)
				HStack {
					ColorPicker("Icon Color", selection: $lockIconColorUnlocked)
					Button(action: {
						lockIconColorUnlocked = Color.accentColor
					}) {
						Image(systemName: "arrow.counterclockwise.circle")
					}.padding(.leading, 5)
				}.padding(.vertical, 5)
				HStack {
					Spacer()
					Button("Reset") {
						self.resetLockUnlocked = true
					}
					.alert(isPresented: $resetLockUnlocked) {
						Alert(
							title: Text("Are you sure?"),
							message: Text("This will reset all preferences for this view back to the default!"),
							primaryButton: .destructive(Text("Reset")) {
								withAnimation(.spring()) {
									self.lockNeonColorUnlocked = Color.green
									self.lockNeonMulUnlocked = 1
									self.lockBgColorUnlocked = Color.white
									self.lockIconColorUnlocked = Color.accentColor
								}
							},
							secondaryButton: .cancel()
						)
					}
					Spacer()
				}.padding(.vertical, 5)
			}.padding(.bottom, 5)
			Section(header: Text("Locked")) {
				BasicNeonOptions(
					mul: $lockNeonMulLocked,
					color: $lockNeonColorLocked,
					bg: $lockBgColorLocked,
					defaultColor: Color.red
				).padding(.vertical, 5)
				HStack {
					ColorPicker("Icon Color", selection: $lockIconColorLocked)
					Button(action: {
						lockIconColorLocked = Color.accentColor
					}) {
						Image(systemName: "arrow.counterclockwise.circle")
					}.padding(.leading, 5)
				}.padding(.vertical, 5)
				HStack {
					Spacer()
					Button("Reset") {
						self.resetLockLocked = true
					}
					.alert(isPresented: $resetLockLocked) {
						Alert(
							title: Text("Are you sure?"),
							message: Text("This will reset all preferences for this view back to the default!"),
							primaryButton: .destructive(Text("Reset")) {
								withAnimation(.spring()) {
									self.lockNeonColorLocked = Color.red
									self.lockNeonMulLocked = 1
									self.lockBgColorLocked = Color.white
									self.lockIconColorLocked = Color.accentColor
								}
							},
							secondaryButton: .cancel()
						)
					}
					Spacer()
				}.padding(.vertical, 5)
			}.padding(.top, 5)
		}
	}

	var body: some View {
		VStack {
			Picker(selection: $popup, label: EmptyView()) {
				Image(systemName: "camera.fill").tag(0)
				Image(systemName: "flashlight.on.fill").tag(1)
				Image(systemName: "lock.open.fill").tag(2)
			}
			.pickerStyle(SegmentedPickerStyle())
			.padding(.bottom)
			switch popup {
			case 0:
				CameraPreferences()
			case 1:
				FlashlightPreferences()
			case 2:
				LockPreferences()
			default:
				EmptyView()
			}
		}
	}
}
