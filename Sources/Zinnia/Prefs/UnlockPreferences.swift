//  Copyright (c) 2021 Lucy <lucy@absolucy.moe>
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI

struct UnlockPrefs: View {
	@Preference("unlockEnabled", identifier: ZinniaPreferences.identifier) var unlockEnabled = true
	@Preference("unlockBgColor", identifier: ZinniaPreferences.identifier) var unlockBgColor = Color.white
	@Preference("unlockNeonMul", identifier: ZinniaPreferences.identifier) var unlockNeonMul: Double = 1
	@Preference("unlockNeonColor", identifier: ZinniaPreferences.identifier) var unlockNeonColor = Color.purple
	@Preference("unlockIconColor", identifier: ZinniaPreferences.identifier) var unlockIconColor = Color.accentColor
	@Preference("unlockPadding", identifier: ZinniaPreferences.identifier) var unlockPadding: Double = 9

	@State var confirmReset = false

	var body: some View {
		Section {
			HStack {
				Spacer()
				UnlockButtonView()
					.padding()
					.border(Color.secondary)
					.highPriorityGesture(DragGesture())
					.highPriorityGesture(TapGesture()).padding(.vertical, 5)
				Spacer()
			}
			Toggle("Enabled", isOn: $unlockEnabled).padding(.vertical, 5)
			HStack {
				Text("Padding")
				Text(String(format: "%.0f", unlockPadding))
					.font(.system(.caption, design: .monospaced))
				Spacer()
				Slider(value: $unlockPadding, in: 0 ... 64)
				Button(action: {
					unlockPadding = 9
				}) {
					Image(systemName: "arrow.counterclockwise.circle")
				}.padding(.leading, 5)
			}.padding(.vertical, 5)
			BasicNeonOptions(
				mul: $unlockNeonMul,
				color: $unlockNeonColor,
				bg: $unlockBgColor
			).padding(.vertical, 5)
			HStack {
				ColorPicker("Icon Color", selection: $unlockIconColor)
				Button(action: {
					self.unlockIconColor = Color.accentColor
				}) {
					Image(systemName: "arrow.counterclockwise.circle")
				}.padding(.leading, 5)
			}.padding(.vertical, 5)
			HStack {
				Spacer()
				Button("Reset") {
					self.confirmReset = true
				}
				.alert(isPresented: self.$confirmReset) {
					Alert(
						title: Text("Are you sure?"),
						message: Text("This will reset all preferences for this view back to the default!"),
						primaryButton: .destructive(Text("Reset")) {
							withAnimation(.spring()) {
								self.unlockBgColor = Color.white
								self.unlockNeonMul = 1
								self.unlockNeonColor = Color.purple
								self.unlockIconColor = Color.accentColor
							}
						},
						secondaryButton: .cancel()
					)
				}
				Spacer()
			}.padding(.bottom, 5)
		}
	}
}
