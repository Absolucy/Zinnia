import CryptoKit
import Foundation
import SwiftUI
import SystemConfiguration.CaptiveNetwork
import ZinniaC
#if !THEOS_SWIFT
	import NomaePreferences
#endif

@_cdecl("runDrm")
internal func runDrm() {
	NSLog("Zinnia: Running DRM")
	ZinniaDRM.requestTicket()
}

@_cdecl("makeUnlockButton")
internal func makeUnlockButton(
	_ unlock: @convention(block) @escaping () -> Void,
	_ camera: @convention(block) @escaping () -> Void
) -> UIViewController {
	UIHostingController(rootView: UnlockButtonView(unlock: unlock, camera: camera)
		.frame(height: UIScreen.main.bounds.width * 0.375 * 2))
}

@_cdecl("makeTimeDate")
internal func makeTimeDate() -> UIViewController {
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
		ZinniaSharedData.global.unlocked = true
	case 0x3:
		ZinniaSharedData.global.unlocked = false
		ZinniaSharedData.global.menuOpenProgress = 0
		ZinniaSharedData.global.draggingMenuOpen = false
	default:
		NSLog("Zinnia: unknown lock state \(state)")
	}
}

@_cdecl("consumeUnlocked")
internal func consumeUnlocked(_ state: Bool) {
	ZinniaSharedData.global.unlocked = state
}

private enum ZinniaInterface {
	@Preference("enabled", identifier: ZinniaPreferences.identifier) internal static var enabled = true
}
