//
//  SwiftUIView.swift
//
//
//  Created by Aspen on 4/7/21.
//

import SwiftUI

public struct LockPopup: View {
	@ObservedObject var globals = ZinniaSharedData.global
	public var unlock: () -> Void

	public var body: some View {
		Button(action: unlock, label: {
			Circle()
				.frame(width: UIScreen.main.bounds.width * 0.15, height: UIScreen.main.bounds.width * 0.15)
				.foregroundColor(self.globals.unlocked ? ZinniaPreferences.lockBgColorUnlocked : ZinniaPreferences
					.lockBgColorLocked)
				.modifier(
					NeonEffect(
						base: Circle(),
						color: self.globals.unlocked ? ZinniaPreferences.lockNeonColorUnlocked : ZinniaPreferences.lockNeonColorLocked,
						brightness: 0.1,
						innerSize: 1.5 *
							(self.globals.unlocked ? ZinniaPreferences.lockNeonMulUnlocked : ZinniaPreferences.lockNeonMulLocked),
						middleSize: 3 *
							(self.globals.unlocked ? ZinniaPreferences.lockNeonMulUnlocked : ZinniaPreferences.lockNeonMulLocked),
						outerSize: 5 *
							(self.globals.unlocked ? ZinniaPreferences.lockNeonMulUnlocked : ZinniaPreferences.lockNeonMulLocked),
						innerBlur: 3,
						blur: 6
					)
				)
				.overlay(
					Image(systemName: self.globals.unlocked ? "lock.open" : "lock")
						.resizable()
						.aspectRatio(contentMode: .fit)
						.frame(width: UIScreen.main.bounds.width * 0.15 * 0.5, height: UIScreen.main.bounds.width * 0.15 * 0.5)
						.foregroundColor(self.globals.unlocked ? ZinniaPreferences.lockIconColorUnlocked : ZinniaPreferences
							.lockIconColorLocked)
						.padding()
						.allowsHitTesting(false)
				)
		}).padding()
	}
}
