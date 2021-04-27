#if !THEOS_SWIFT
	// import NomaePreferences
#endif
import SwiftUI

extension Bundle: ObservableObject {}

class RootPreferences: NomaePreferencesController {
	override var suiView: AnyView {
		get { AnyView(PreferencesView()) }
		set { super.suiView = newValue }
	}
}

@_cdecl("zinnia_camera")
internal func zinnia_camera() {}

@_cdecl("zinnia_unlock")
internal func zinnia_unlock() {}
