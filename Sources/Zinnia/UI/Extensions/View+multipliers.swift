import SwiftUI

internal extension View {
	var circleMul: CGFloat {
		UIDevice.current.userInterfaceIdiom == .pad ? 0.2 : 0.25
	}

	var radiusMul: CGFloat {
		UIDevice.current.userInterfaceIdiom == .pad ? 0.225 : 0.3
	}
}
