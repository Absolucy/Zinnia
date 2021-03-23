#if !targetEnvironment(simulator)
	import Foundation
	import Orion
	import SwiftUI
	import SystemConfiguration.CaptiveNetwork
	import ZinniaC

	struct ZinniaTweak: TweakWithBackend {
		static var backend = Backends.Automatic()
		typealias BackendType = Backends.Automatic
	}

	class ZinniaSharedData: ObservableObject {
		static let global = ZinniaSharedData()
		@Published var associated = false
		@Published var wifi_strength = 0
		@Published var lte_strength = 0
		@Published var unlocked = false
	}

	class UIVHook: ClassHook<UIViewController> {
		func _canShowWhileLocked() -> Bool {
			true
		}
	}

	class SBWifiHook: ClassHook<SBWiFiManager> {
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
		func _updateActiveBars() {
			orig._updateActiveBars()
			ZinniaSharedData.global.lte_strength = Int(target.numberOfActiveBars)
		}
	}

	class LockStateHook: ClassHook<SASLockStateMonitor> {
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

	class LockScreenHook: ClassHook<CSCoverSheetViewController> {
		lazy var host = UIHostingController(rootView: LockScreenView(unlock: zinnia_unlock))

		func viewDidLoad() {
			// Normally we wouldn't call orig at all,
			// but this conflicts with tweaks like Eneko,
			// so instead we just remove all the subviews from child view controllers
			orig.viewDidLoad()
			for sub in target.children {
				let type = String(describing: sub)
				NSLog("Zinnia: \(type)")
				if type.contains("DateView") || type.contains("FixedFooter") || type.contains("TeachableMoments") || type
					.contains("ProudLock")
				{
					sub.view.removeFromSuperview()
				}
			}
			self.host.view.backgroundColor = .clear
			self.host.view.frame = target.view.frame
			target.addChild(self.host)
			target.view.addSubview(self.host.view)
			self.host.didMove(toParent: target)
		}

		final func zinnia_unlock() {
			Dynamic.SpringBoard
				.as(interface: SpringBoardInterface.self)
				.sharedApplication()
				._simulateHomeButtonPress()
		}
	}
#endif
