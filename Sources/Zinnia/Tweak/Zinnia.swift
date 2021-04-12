import CryptoKit
import Foundation
import SwiftUI
import SystemConfiguration.CaptiveNetwork
import ZinniaC
#if !THEOS_SWIFT
	import NomaePreferences
#endif

@objc public class ZinniaInterface: NSObject {
	@Preference("enabled", identifier: ZinniaPreferences.identifier) private static var enabled = true

	@objc public static func makeUnlockButton(
		_ unlock: @convention(block) @escaping () -> Void,
		camera: @convention(block) @escaping () -> Void
	) -> UIViewController {
		ZinniaDRM.instance.requestTicket()
		return UIHostingController(rootView: UnlockButtonView(unlock: unlock, camera: camera)
			.frame(height: UIScreen.main.bounds.width * 0.375 * 2))
	}

	@objc public static func makeTimeDate() -> UIViewController {
		UIHostingController(rootView: TimeDateView().padding(.top, 64))
	}

	@objc public static func tweakEnabled() -> Bool {
		self.enabled
	}

	@objc public static func consumeLockState(_ state: UInt64) {
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

	@objc public static func consumeUnlocked(_ state: Bool) {
		ZinniaSharedData.global.unlocked = state
	}
}
