import Foundation
import UIKit

extension UIColor {
	static func blend(color1: UIColor, intensity1: CGFloat = 0.5, color2: UIColor,
	                  intensity2: CGFloat = 0.5) -> UIColor
	{
		let total = intensity1 + intensity2
		let l1 = intensity1 / total
		let l2 = intensity2 / total
		guard l1 > 0 else { return color2 }
		guard l2 > 0 else { return color1 }
		var (r1, g1, b1, a1): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
		var (r2, g2, b2, a2): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)

		color1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
		color2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

		return UIColor(
			red: l1 * r1 + l2 * r2,
			green: l1 * g1 + l2 * g2,
			blue: l1 * b1 + l2 * b2,
			alpha: l1 * a1 + l2 * a2
		)
	}

	static func lerp(start: UIColor, end: UIColor, progress: CGFloat) -> UIColor {
		var (sr, sg, sb, _sa): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
		var (er, eg, eb, _ea): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
		start.getRed(&sr, green: &sg, blue: &sb, alpha: &_sa)
		end.getRed(&er, green: &eg, blue: &eb, alpha: &_ea)

		let r = (1.0 - progress) * sr + progress * er
		let g = (1.0 - progress) * sg + progress * eg
		let b = (1.0 - progress) * sb + progress * eb

		return UIColor(red: r, green: g, blue: b, alpha: 1.0)
	}
}
