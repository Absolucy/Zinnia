import SwiftUI
import ZinniaC

struct LockScreenView: View {
	public var unlock: () -> Void
	public var camera: () -> Void

	var body: some View {
		VStack {
			TimeDateView()
				.padding(.vertical, 30)
			QuickGlanceView()
			Spacer().allowsHitTesting(false)
			UnlockButtonView(unlock: unlock, camera: camera)
		}
	}
}

#if targetEnvironment(simulator)
	struct LockScreenView_Previews: PreviewProvider {
		static var previews: some View {
			LockScreenView {}
				.preferredColorScheme(.dark)
				.previewLayout(.device)
				.previewDevice("iPhone 11")
			LockScreenView {}
				.preferredColorScheme(.dark)
				.previewLayout(.device)
				.previewDevice("iPad (8th generation)")
		}
	}
#endif
