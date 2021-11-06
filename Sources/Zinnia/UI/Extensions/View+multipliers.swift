//  Copyright (c) 2021 Lucy <lucy@absolucy.moe>
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI

internal extension View {
	var circleMul: CGFloat {
		UIDevice.current.userInterfaceIdiom == .pad ? 0.2 : 0.25
	}

	var radiusMul: CGFloat {
		UIDevice.current.userInterfaceIdiom == .pad ? 0.225 : 0.3
	}
}
