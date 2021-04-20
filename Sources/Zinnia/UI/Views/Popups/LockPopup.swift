#if !THEOS_SWIFT
	import NomaePreferences
#endif
import SwiftUI
import ZinniaC

struct LockPopup: View {
	internal var action: () -> Void

	@ObservedObject var globals = ZinniaSharedData.global

	@Preference("lockBgColorUnlocked", identifier: ZinniaPreferences.identifier) var lockBgColorUnlocked = Color.primary
	@Preference("lockBgColorLocked", identifier: ZinniaPreferences.identifier) var lockBgColorLocked = Color.primary
	@Preference("lockNeonMulUnlocked", identifier: ZinniaPreferences.identifier) var lockNeonMulUnlocked: Double = 1
	@Preference("lockNeonMulLocked", identifier: ZinniaPreferences.identifier) var lockNeonMulLocked: Double = 1
	@Preference("lockNeonColorUnlocked", identifier: ZinniaPreferences.identifier) var lockNeonColorUnlocked = Color.green
	@Preference("lockNeonColorLocked", identifier: ZinniaPreferences.identifier) var lockNeonColorLocked = Color.red
	@Preference("lockIconColorUnlocked", identifier: ZinniaPreferences.identifier) var lockIconColorUnlocked = Color
		.accentColor
	@Preference("lockIconColorLocked", identifier: ZinniaPreferences.identifier) var lockIconColorLocked = Color
		.accentColor

	var body: some View {
		if !ZinniaDRM.ticketAuthorized() {
			EmptyView()
		} else {
			Button(action: action, label: {
				Circle()
					.frame(width: mulByWidth(radiusMul / 2), height: mulByWidth(radiusMul / 2))
					.foregroundColor(self.globals.unlocked ? lockBgColorUnlocked : lockBgColorLocked)
					.modifier(
						NeonEffect(
							base: Circle(),
							color: self.globals.unlocked ? lockNeonColorUnlocked : lockNeonColorLocked,
							brightness: 0.1,
							innerSize: 1.5 *
								(self.globals.unlocked ? lockNeonMulUnlocked : lockNeonMulLocked),
							middleSize: 3 *
								(self.globals.unlocked ? lockNeonMulUnlocked : lockNeonMulLocked),
							outerSize: 5 *
								(self.globals.unlocked ? lockNeonMulUnlocked : lockNeonMulLocked),
							innerBlur: 3,
							blur: 6
						)
					)
					.overlay(
						Image(systemName: self.globals.unlocked ? "lock.open" : "lock")
							.resizable()
							.aspectRatio(contentMode: .fit)
							.frame(width: mulByWidth(radiusMul / 2) * 0.5, height: mulByWidth(radiusMul / 2) * 0.5)
							.foregroundColor(self.globals.unlocked ? lockIconColorUnlocked : lockIconColorLocked)
							.padding()
					)
			}).padding()
		}
	}
}
