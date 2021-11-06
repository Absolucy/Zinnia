//  Copyright (c) 2021 Lucy <lucy@absolucy.moe>
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SwiftUI
import ZinniaC

@_cdecl("makeUnlockButton")
internal func makeUnlockButton() -> UIViewController {
	UIHostingController(rootView: UnlockButtonView())
}

@_cdecl("makeUnlockPopups")
internal func makeUnlockPopups() -> UIViewController? {
	UIHostingController(rootView: UnlockPopupView())
}

@_cdecl("makeTimeDate")
internal func makeTimeDate() -> UIViewController? {
	UIHostingController(rootView: TimeDateView().padding(.top, 64))
}

@_cdecl("tweakEnabled")
internal func tweakEnabled() -> Bool {
	ZinniaInterface.enabled
}

@_cdecl("consumeLockState")
internal func consumeLockState(_ state: UInt64) {
	switch state {
	case 0x0, 0x1:
		SharedData.instance.unlocked = true
	case 0x3:
		SharedData.instance.unlocked = false
		SharedData.instance.menuOpenProgress = 0
		SharedData.instance.draggingMenuOpen = false
	default:
		NSLog("[Zinnia] unknown lock state \(state)")
	}
}

@_cdecl("consumeUnlocked")
internal func consumeUnlocked(_ state: Bool) {
	SharedData.instance.unlocked = state
}

private enum ZinniaInterface {
	@Preference("enabled", identifier: ZinniaPreferences.identifier) internal static var enabled = true
}
