#if !targetEnvironment(simulator)
	import Foundation
	import Orion
	import SwiftUI
	import ZinniaC

	class ZinniaHostingController: UIViewController {
		let ls_view = LockScreenView()

		override func viewDidLoad() {
			let host = UIHostingController(rootView: ls_view)
			host.view.backgroundColor = .clear
			self.addChild(host)
			host.view.frame = self.view.frame
			self.view.addSubview(host.view)
			host.didMove(toParent: self)
		}
	}

	class UIVHook: ClassHook<UIViewController> {
		func _canShowWhileLocked() -> Bool {
			true
		}
	}

	class DateTimeHook: ClassHook<SBFLockScreenDateViewController> {
		let host = ZinniaHostingController()
		func viewDidLoad() {
			target.addChild(self.host)
			self.host.view.frame = target.view.frame
			target.view.addSubview(self.host.view)
			self.host.didMove(toParent: target)
			/* let tmp = host.view
			 host.view = nil
			 target.view = tmp */
		}
	}
#endif
