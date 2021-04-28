import CryptoKit
import Foundation
import SwiftUI
import SystemConfiguration.CaptiveNetwork
import ZinniaC

@_cdecl("runDrm")
internal func runDrm() {
	#if DRM
		if isValidated() {
			return
		}
		#if TRIAL
			if let ticket = ZinniaDRM.ticket, !ticket.validTime(), ticket.isSignatureValid() {
				UIAlertView(
					title: getStr(0),
					message: getStr(14),
					delegate: nil,
					cancelButtonTitle: getStr(5)
				)
				.show()
				return
			}
		#endif
		#if DEBUG
			NSLog("Zinnia: running DRM...")
		#endif
		ZinniaDRM.requestTicket()
	#endif
}

@_cdecl("isValidated")
internal func isValidated() -> Bool {
	#if DRM
		return ZinniaDRM.ticketAuthorized()
	#else
		return true
	#endif
}

@_cdecl("makeUnlockButton")
internal func makeUnlockButton() -> UIViewController {
	UIHostingController(rootView: UnlockButtonView())
}

@_cdecl("makeUnlockPopups")
internal func makeUnlockPopups() -> UIViewController {
	UIHostingController(rootView: UnlockPopupView())
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
