//
//  NomaePreferencesController.swift
//  NomaePreferences
//
//  Created by Eamon Tracey.
//  Copyright © 2021 Eamon Tracey. All rights reserved.
//

import SwiftUI

/// A view controller that loads a SwiftUI `View`. Subclass this and override `suiView`
internal class NomaePreferencesController: PreferenceLoaderController {
	/// SwiftUI `View` to override with your custom preferences view
	internal var suiView = AnyView(EmptyView())

	override internal func loadView() {
		let host = UIHostingController(rootView: suiView)
		let tmp = host.view
		host.view = nil
		view = tmp
	}
}
