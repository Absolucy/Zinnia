import SwiftUI

struct UnlockPrefs: View {
	@Preference("unlockBgColor", identifier: ZinniaPreferences.identifier) var unlockBgColor = Color.white
	@Preference("unlockNeonMul", identifier: ZinniaPreferences.identifier) var unlockNeonMul: Double = 1
	@Preference("unlockNeonColor", identifier: ZinniaPreferences.identifier) var unlockNeonColor = Color.purple
	@Preference("unlockIconColor", identifier: ZinniaPreferences.identifier) var unlockIconColor = Color.accentColor

	@State var confirmReset = false

	var body: some View {
		Section {
			UnlockButtonView()
				.padding()
				.border(Color.secondary)
				.highPriorityGesture(DragGesture())
				.highPriorityGesture(TapGesture())
			BasicNeonOptions(
				mul: $unlockNeonMul,
				color: $unlockNeonColor,
				bg: $unlockBgColor
			)
			HStack {
				ColorPicker("Icon Color", selection: $unlockIconColor)
				Button(action: {
					self.unlockIconColor = Color.accentColor
				}) {
					Image(systemName: "arrow.counterclockwise.circle")
				}.padding(.leading, 5)
			}
			HStack {
				Spacer()
				Button("Reset") {
					self.confirmReset = true
				}
				.alert(isPresented: self.$confirmReset) {
					Alert(
						title: Text("Are you sure?"),
						message: Text("This will reset all preferences for this view back to the default!"),
						primaryButton: .destructive(Text("Reset")) {
							withAnimation(.spring()) {
								self.unlockBgColor = Color.white
								self.unlockNeonMul = 1
								self.unlockNeonColor = Color.purple
								self.unlockIconColor = Color.accentColor
							}
						},
						secondaryButton: .cancel()
					)
				}
				Spacer()
			}
		}
	}
}
