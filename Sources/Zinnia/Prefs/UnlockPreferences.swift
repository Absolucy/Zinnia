import SwiftUI

struct UnlockPrefs: View {
	@Preference("unlockBgColor", identifier: ZinniaPreferences.identifier) var unlockBgColor = Color.white
	@Preference("unlockNeonMul", identifier: ZinniaPreferences.identifier) var unlockNeonMul: Double = 1
	@Preference("unlockNeonColor", identifier: ZinniaPreferences.identifier) var unlockNeonColor = Color.purple
	@Preference("unlockIconColor", identifier: ZinniaPreferences.identifier) var unlockIconColor = Color.accentColor
	@Preference("unlockPadding", identifier: ZinniaPreferences.identifier) var unlockPadding: Double = 9

	@State var confirmReset = false

	var body: some View {
		Section {
			UnlockButtonView()
				.padding()
				.border(Color.secondary)
				.highPriorityGesture(DragGesture())
				.highPriorityGesture(TapGesture())
			HStack {
				Text("Padding")
				Text(String(format: "%.0f", unlockPadding))
					.font(.system(.caption, design: .monospaced))
				Spacer()
				Slider(value: $unlockPadding, in: 0 ... 64)
				Button(action: {
					unlockPadding = 9
				}) {
					Image(systemName: "arrow.counterclockwise.circle")
				}.padding(.leading, 5)
			}
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
