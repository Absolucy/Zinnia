import Foundation
import SwiftUI
import SystemConfiguration.CaptiveNetwork
import ZinniaC
//
// import ZinniaUI
// import NomaePreferences

@objc public class ZinniaInterface: NSObject {
	@Preference("enabled", identifier: ZinniaPreferences.identifier) static var enabled = true

	@objc public static func makeUnlockButton(
		_ unlock: @convention(block) @escaping () -> Void,
		camera: @convention(block) @escaping () -> Void
	) -> UIViewController {
		UIHostingController(rootView: UnlockButtonView(unlock: unlock, camera: camera)
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
		default:
			NSLog("Zinnia: unknown lock state \(state)")
		}
	}

	@objc public static func consumeUnlocked(_ state: Bool) {
		ZinniaSharedData.global.unlocked = state
	}
}

/*
 import Orion

 struct Zinnia: TweakWithBackend {
 	static var backend = Backends.Automatic()
 	typealias BackendType = Backends.Automatic

 	@Preference("enabled", identifier: ZinniaPreferences.identifier) var enabled = true

 	init() {
 		if self.enabled {
 			ZinniaHooks().activate()
 		}
 	}
 }

 struct ZinniaHooks: HookGroup {}

 class UIVHook: ClassHook<UIViewController> {
 	typealias Group = ZinniaHooks
 	func _canShowWhileLocked() -> Bool {
 		true
 	}
 }

 class SBWifiHook: ClassHook<SBWiFiManager> {
 	typealias Group = ZinniaHooks
 	func isAssociated() -> Bool {
 		let associated = orig.isAssociated()
 		ZinniaSharedData.global.associated = associated
 		return associated
 	}

 	func signalStrengthBars() -> Int {
 		let strength = orig.signalStrengthBars()
 		ZinniaSharedData.global.wifi_strength = strength
 		return strength
 	}
 }

 class SBLTEHook: ClassHook<_UIStatusBarCellularSignalView> {
 	typealias Group = ZinniaHooks
 	func _updateActiveBars() {
 		orig._updateActiveBars()
 		ZinniaSharedData.global.lte_strength = Int(target.numberOfActiveBars)
 	}
 }

 class LockStateHook: ClassHook<SASLockStateMonitor> {
 	typealias Group = ZinniaHooks
 	func setUnlockedByTouchID(_ state: Bool) {
 		orig.setUnlockedByTouchID(state)
 		ZinniaSharedData.global.unlocked = state
 	}

 	func setLockState(_ state: UInt64) {
 		orig.setLockState(state)
 		if state == 0x1 {
 			ZinniaSharedData.global.unlocked = true
 		} else if state == 0x3 {
 			ZinniaSharedData.global.unlocked = false
 		} else {
 			NSLog("Zinnia: unknown lock state \(state)")
 		}
 	}
 }

 @objc protocol SpringBoardInterface {
 	func sharedApplication() -> SpringBoard
 }

 class NoHook: ClassHook<CSProudLockViewController> {
 	typealias Group = ZinniaHooks
 	func viewDidLoad() {}
 }

 class NoHook2: ClassHook<CSQuickActionsViewController> {
 	typealias Group = ZinniaHooks
 	func viewDidLoad() {}
 }

 class NoHook3: ClassHook<CSQuickActionsButton> {
 	typealias Group = ZinniaHooks
 	func initWithFrame(_: CGRect) -> Target {
 		orig.initWithFrame(CGRect(x: 0, y: 0, width: 0, height: 0))
 	}

 	func layoutSubviews() {}
 }

 class LockScreenHook: ClassHook<CSCoverSheetViewController> {
 	typealias Group = ZinniaHooks
 	lazy var buttonHost =
 		UIHostingController(rootView:
 			AnyView(
 				UnlockButtonView(unlock: self.zinnia_unlock, camera: self.zinnia_camera)
 					.frame(height: UIScreen.main.bounds.width * 0.375 * 2)
 			))
 	lazy var timeDateHost = UIHostingController(rootView: AnyView(TimeDateView().padding(.top, 64)))

 	func viewDidLoad() {
 		orig.viewDidLoad()

 		for sub in target.children {
 			let type_name = String(describing: type(of: sub))
 			if type_name.contains("DateView")
 				|| type_name.contains("FixedFooter")
 				|| type_name.contains("TeachableMoments")
 				|| type_name.contains("ProudLock")
 				|| type_name.contains("QuickActions")
 			{
 				sub.view.removeFromSuperview()
 			}
 		}

 		self.buttonHost.view.backgroundColor = .clear
 		self.buttonHost.view.frame = target.view.frame
 		target.addChild(self.buttonHost)
 		target.view.addSubview(self.buttonHost.view)

 		self.buttonHost.view.translatesAutoresizingMaskIntoConstraints = false
 		NSLayoutConstraint.activate([
 			self.buttonHost.view.leftAnchor.constraint(equalTo: target.view.leftAnchor),
 			self.buttonHost.view.rightAnchor.constraint(equalTo: target.view.rightAnchor),
 			self.buttonHost.view.bottomAnchor.constraint(equalTo: target.view.bottomAnchor),
 		])

 		self.buttonHost.didMove(toParent: target)

 		self.timeDateHost.view.backgroundColor = .clear
 		self.timeDateHost.view.frame = target.view.frame
 		target.addChild(self.timeDateHost)
 		target.view.addSubview(self.timeDateHost.view)

 		self.timeDateHost.view.translatesAutoresizingMaskIntoConstraints = false
 		NSLayoutConstraint.activate([
 			self.timeDateHost.view.leftAnchor.constraint(equalTo: target.view.leftAnchor),
 			self.timeDateHost.view.rightAnchor.constraint(equalTo: target.view.rightAnchor),
 			self.timeDateHost.view.topAnchor.constraint(equalTo: target.view.topAnchor),
 		])

 		self.timeDateHost.didMove(toParent: target)
 	}

 	final func zinnia_unlock() {
 		Dynamic.SpringBoard
 			.as(interface: SpringBoardInterface.self)
 			.sharedApplication()
 			._simulateHomeButtonPress()
 	}

 	final func zinnia_camera() {
 		target.activatePage(1, animated: true, withCompletion: nil)
 	}
 }
 */
