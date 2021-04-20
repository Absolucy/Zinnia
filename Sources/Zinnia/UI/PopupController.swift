import Foundation
import SwiftUI
import UIKit
import ZinniaC

internal class ZinniaPopupController: ObservableObject {
	internal static let global = ZinniaPopupController()

	@Published internal var popups: [(AnyView, () -> Void)] = getPopups()
	@Published internal var flashlight: AVFlashlight? = {
		if AVFlashlight.hasFlashlight() {
			return AVFlashlight()
		} else {
			return nil
		}
	}()

	internal static func toggleFlashlight() {
		if let flashlight = ZinniaPopupController.global.flashlight {
			if flashlight.flashlightLevel > 0 {
				_ = flashlight.setFlashlightLevel(0, withError: nil)
				flashlight.turnPowerOff()
			} else {
				_ = flashlight.setFlashlightLevel(1, withError: nil)
			}
		}
	}

	private static func getPopups() -> [(AnyView, () -> Void)] {
		var popups: [(AnyView, () -> Void)] = []
		popups.append((AnyView(CameraPopup(action: zinnia_camera)), zinnia_camera))
		popups.append((AnyView(LockPopup(action: zinnia_unlock)), zinnia_unlock))
		if AVFlashlight.hasFlashlight() {
			popups
				.append((AnyView(FlashlightPopup()), ZinniaPopupController.toggleFlashlight))
		}
		popups.reverse()
		return popups
	}
}
