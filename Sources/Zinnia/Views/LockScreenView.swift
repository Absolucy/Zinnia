import SwiftUI
import ZinniaC

struct LockScreenView: View {
	var body: some View {
		ZStack {
			Rectangle().foregroundColor(.purple)
			VStack {
				TimeDateView()
					.padding(.top)
				QuickGlanceView()
				UnlockButtonView().padding(.vertical)
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
