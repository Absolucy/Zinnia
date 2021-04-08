import Foundation

public class ZinniaSharedData: ObservableObject {
	public static let global = ZinniaSharedData()
	@Published public var associated = false
	@Published public var wifi_strength = 0
	@Published public var lte_strength = 0
	@Published public var unlocked = false
}
