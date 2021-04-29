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
					title: getStr("UI->DRM->Header"),
					message: getStr("UI->DRM->Trial->Expired"),
					delegate: nil,
					cancelButtonTitle: getStr("UI->DRM->Fail Button")
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
internal func makeUnlockPopups() -> UIViewController? {
	#if DRM
		if !ZinniaDRM.ticketAuthorized() {
			return nil
		}
	#endif
	return UIHostingController(rootView: UnlockPopupView())
}

@_cdecl("makeTimeDate")
internal func makeTimeDate() -> UIViewController? {
	#if DRM
		if !ZinniaDRM.ticketAuthorized() {
			return nil
		}
	#endif
	return UIHostingController(rootView: TimeDateView().padding(.top, 64))
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
