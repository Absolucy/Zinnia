//  Copyright (c) 2021 Lucy <lucy@absolucy.moe>
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SwiftUI
import UIKit

struct UnlockPopupView: View {
	@ObservedObject private var popupController = ZinniaPopupController.global
	@ObservedObject private var globals = SharedData.instance

	@Preference("unlockEnabled", identifier: ZinniaPreferences.identifier) var unlockEnabled = true
	@Preference("unlockPadding", identifier: ZinniaPreferences.identifier) private var unlockPadding: Double = 9

	@ViewBuilder private func Popup(_ index: Int) -> some View {
		popupController.popups[index]
			.0
			.rotationEffect(.degrees(-Double((270 / popupController.popups.count) * index)))
			.frame(width: mulByWidth(radiusMul / 2), height: mulByWidth(radiusMul / 2))
			.offset(x: -mulByWidth(radiusMul))
			.rotationEffect(.degrees(Double((270 / popupController.popups.count) * index)))
			.opacity(globals
				.menuOpenProgress >= 1 ? (globals.draggingMenuOpen ? (globals.selected == index ? 1 : 0.5) : 1) :
				Double(globals.menuOpenProgress))
			.scaleEffect(globals.menuOpenProgress)
	}

	var body: some View {
		if !unlockEnabled {
			EmptyView()
		} else {
			VStack(alignment: .center) {
				Spacer()
				ZStack {
					ForEach(0 ..< popupController.popups.count, id: \.self) { index in
						Popup(index)
					}
				}
			}
			.frame(width: UIScreen.main.bounds.width, height: globals.menuIsOpen ? mulByWidth(0.375) * 2 : 0)
			.padding([.top, .leading, .trailing])
			.padding(.bottom, CGFloat(unlockPadding) + mulByWidth(radiusMul / 4))
		}
	}
}
