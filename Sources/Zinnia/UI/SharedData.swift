import Foundation

class ZinniaSharedData: ObservableObject {
	static let global = ZinniaSharedData()
	@Published var associated = false
	@Published var wifi_strength = 0
	@Published var lte_strength = 0
	@Published var unlocked = false

	init() {}

	init(unlocked: Bool) {
		self.unlocked = unlocked
	}
}
