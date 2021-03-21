#if !targetEnvironment(simulator)
	import Foundation
	import Orion
	import SwiftUI
	import SystemConfiguration.CaptiveNetwork
	import ZinniaC
	

	class ZinniaSharedData: ObservableObject {
		static let global = ZinniaSharedData()
		@Published var associated = false
		@Published var wifi_strength = 0
		@Published var lte_strength = 0
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

	class LockScreenHook: ClassHook<CSCoverSheetViewController> {
		lazy var host = UIHostingController(rootView: LockScreenView(unlock: zinnia_unlock))

		func viewDidLoad() {
			NSLog("Zinnia: viewDidLoad")
			self.host.view.backgroundColor = .clear
			self.host.view.frame = target.view.frame
			target.addChild(self.host)
			target.view.addSubview(self.host.view)
			self.host.didMove(toParent: target)
		}

		final func zinnia_unlock() {
			target.setPasscodeLockVisible(true, animated: true)
		}
	}
#endif
