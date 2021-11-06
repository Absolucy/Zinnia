//  Copyright (c) 2021 Lucy <lucy@absolucy.moe>
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

import SwiftUI
#if !THEOS_SWIFT
	import ZinniaC
#endif

internal struct LockScreenView: View {
	internal var body: some View {
		VStack {
			TimeDateView()
				.padding(.vertical, 30)
			Spacer().allowsHitTesting(false)
			UnlockButtonView()
		}
	}
}

struct LockScreenView_Previews: PreviewProvider {
	static var previews: some View {
		LockScreenView()
			.preferredColorScheme(.dark)
			.previewLayout(.device)
			.previewDevice("iPhone 11")
		LockScreenView()
			.preferredColorScheme(.dark)
			.previewLayout(.device)
			.previewDevice("iPad (8th generation)")
	}
}
