import SwiftUI
import ZinniaC

extension Bundle: ObservableObject {}

class RootPreferences: NomaePreferencesController {
	static let run: Void = {
		initialize_string_table()
		return ()
	}()

	override var suiView: AnyView {
		get {
			RootPreferences.run
			return AnyView(PreferencesView())
		}
		set {
			RootPreferences.run
			super.suiView = newValue
		}
	}
}

@_cdecl("zinnia_camera")
internal func zinnia_camera() {}

@_cdecl("zinnia_unlock")
internal func zinnia_unlock() {}

@_cdecl("initTweakFunc")
internal func _initTweakFunc() {}
