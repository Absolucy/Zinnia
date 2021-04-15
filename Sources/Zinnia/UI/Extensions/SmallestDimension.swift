import UIKit

internal func smallestDimension() -> CGFloat {
	min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
}

internal func mulByWidth(_ amt: CGFloat) -> CGFloat {
	smallestDimension() * amt
}
