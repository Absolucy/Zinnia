import SwiftUI
#if !THEOS_SWIFT
	import ZinniaC
#endif

public struct LockScreenView: View {
	public var unlock: () -> Void
	public var camera: () -> Void

	public var body: some View {
		VStack {
			TimeDateView()
				.padding(.vertical, 30)
			QuickGlanceView()
			Spacer().allowsHitTesting(false)
			UnlockButtonView(unlock: unlock, camera: camera)
		}
	}
}

struct LockScreenView_Previews: PreviewProvider {
	static var previews: some View {
		LockScreenView {} camera: {}
			.preferredColorScheme(.dark)
			.previewLayout(.device)
			.previewDevice("iPhone 11")
		LockScreenView {} camera: {}
			.preferredColorScheme(.dark)
			.previewLayout(.device)
			.previewDevice("iPad (8th generation)")
	}
}
