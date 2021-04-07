import Foundation
import SwiftUI

class ZinniaSharedData: ObservableObject {
	static let global = ZinniaSharedData()
	@Published var associated = false
	@Published var wifi_strength = 0
	@Published var lte_strength = 0
	@Published var unlocked = false
}

#if !targetEnvironment(simulator)
	import Orion
	import SystemConfiguration.CaptiveNetwork
	import ZinniaC

	struct ZinniaTweak: TweakWithBackend {
		static var backend = Backends.Automatic()
		typealias BackendType = Backends.Automatic
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
		lazy var buttonHost =
			UIHostingController(rootView: AnyView(UnlockButtonView(unlock: self.zinnia_unlock, camera: self.zinnia_camera)
						.padding(.bottom, 16)))
		lazy var timeDateHost = UIHostingController(rootView: AnyView(TimeDateView().padding(.top, 64)))

		func viewDidLoad() {
			// Normally we wouldn't call orig at all,
			// but this conflicts with tweaks like Eneko,
			// so instead we just remove all the subviews from child view controllers
			orig.viewDidLoad()
			for sub in target.children {
				let type = String(describing: sub)
				if type.contains("DateView")
					|| type.contains("FixedFooter")
					|| type.contains("TeachableMoments")
					|| type.contains("ProudLock")
					|| type.contains("QuickActions")
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
			zinnia_open_the_damn_camera()
		}
	}
#endif
