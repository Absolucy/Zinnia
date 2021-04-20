import SwiftUI
#if !THEOS_SWIFT
	import ZinniaC
#endif

internal struct LockScreenView: View {
	internal var body: some View {
		if !ZinniaDRM.ticketAuthorized() {
			EmptyView()
		} else {
			VStack {
				TimeDateView()
					.padding(.vertical, 30)
				Spacer().allowsHitTesting(false)
				UnlockButtonView()
			}
		}
	}
}

struct LockScreenView_Previews: PreviewProvider {
	static var previews: some View {
		LockScreenView()
			.preferredColorScheme(.dark)
			.previewLayout(.device)
			.previewDevice("iPhone 11")
		LockScreenView()
			.preferredColorScheme(.dark)
			.previewLayout(.device)
			.previewDevice("iPad (8th generation)")
	}
}
