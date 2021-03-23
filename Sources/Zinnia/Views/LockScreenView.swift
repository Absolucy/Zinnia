import SwiftUI
import ZinniaC

struct LockScreenView: View {
	public var unlock: () -> Void

	var body: some View {
		ZStack {
			VStack {
				TimeDateView()
					.padding(.top, 24.0)
				QuickGlanceView()
				UnlockButtonView(unlock: unlock)
					.padding(.vertical)
			}
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
