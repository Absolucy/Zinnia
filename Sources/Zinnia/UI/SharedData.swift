import Foundation
import UIKit

internal class ZinniaSharedData: ObservableObject {
	internal static let global = ZinniaSharedData()
	@Published internal var associated = false
	@Published internal var wifi_strength = 0
	@Published internal var lte_strength = 0
	@Published internal var unlocked = false
	@Published internal var menuOpenProgress: CGFloat = 0.0
	@Published internal var draggingMenuOpen = false

	internal init(unlocked: Bool? = nil) {
		self.unlocked = unlocked ?? self.unlocked
	}
}
