//  Copyright (c) 2021 Lucy <lucy@absolucy.moe>
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Foundation
import SwiftUI
import UIKit

internal class SharedData: ObservableObject {
	internal static let instance = SharedData()

	@Published internal var dateTime = Date()
	@Published internal var unlocked = false

	@Published internal var menuIsOpen = false
	@Published internal var menuOpenProgress: CGFloat = 0.0
	@Published internal var draggingMenuOpen = false
	@Published internal var popups: [(AnyView, () -> Void)] = []
	@Published internal var selected: Int?

	internal var timeTimer: Timer?

	internal init(unlocked: Bool? = nil) {
		self.unlocked = unlocked ?? self.unlocked
		startTimers()
	}

	internal func startTimers() {
		stopTimers()
		timeTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
			self.dateTime = Date()
		}
	}

	internal func stopTimers() {
		timeTimer?.invalidate()
		timeTimer = nil
	}
}
