//  Copyright (c) 2021 Lucy <lucy@absolucy.moe>
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
import ZinniaC

extension Bundle: ObservableObject {}

class RootPreferences: UIHostingController<PreferencesView> {
	override init(nibName _: String?,
	              bundle _: Bundle?)
	{
		super.init(rootView: PreferencesView())
		navigationItem.largeTitleDisplayMode = .never
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("stfu xcode")
	}

	@objc var parentController: Any?
	@objc var rootController: Any?
	@objc var specifier: Any?
}

@_cdecl("zinnia_camera")
internal func zinnia_camera() {}

@_cdecl("zinnia_unlock")
internal func zinnia_unlock() {
	NotificationCenter.default.post(name: NSNotification.Name("me.aspenuwu.zinnia.unlock"), object: nil)
}

@_cdecl("initTweakFunc")
internal func _initTweakFunc() {}
