#if !THEOS_SWIFT
	import NomaePreferences
#endif
import SwiftUI

struct TimeDatePrefs: View {
	@Preference("dateFormat", identifier: ZinniaPreferences.identifier) var dateFormat = "MM/dd/yyyy"
	@Preference("timeFormat", identifier: ZinniaPreferences.identifier) var timeFormat = "hh:mm a"
	@Preference("dateTimeNeonMul", identifier: ZinniaPreferences.identifier) var dateTimeNeonMul: Double = 1
	@Preference("dateTimeNeonColor", identifier: ZinniaPreferences.identifier) var dateTimeNeonColor = Color.purple
	@Preference("dateTimeBgColor", identifier: ZinniaPreferences.identifier) var dateTimeBgColor = Color.black
		.opacity(0.75)

	@State var confirmReset = false

	var body: some View {
		Section {
			TimeDateView()
				.padding()
				.border(Color.secondary)
			HStack {
				Text("Date Format")
				Spacer()
				TextField("MM/dd/yyyy", text: $dateFormat)
					.textFieldStyle(RoundedBorderTextFieldStyle())
				Button(action: {
					self.dateFormat = "MM/dd/yyyy"
				}) {
					Image(systemName: "arrow.counterclockwise.circle")
				}.padding(.leading, 5)
			}
			HStack {
				Text("Time Format")
				Spacer()
				TextField("hh:mm a", text: $timeFormat)
					.textFieldStyle(RoundedBorderTextFieldStyle())
				Button(action: {
					self.timeFormat = "hh:mm a"
				}) {
					Image(systemName: "arrow.counterclockwise.circle")
				}.padding(.leading, 5)
			}
			NeonPrefsStuff(
				mul: $dateTimeNeonMul,
				color: $dateTimeNeonColor,
				bg: $dateTimeBgColor,
				defaultBg: Color.black.opacity(0.75)
			)
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
								self.dateFormat = "MM/dd/yyyy"
								self.timeFormat = "hh:mm a"
								self.dateTimeNeonMul = 1
								self.dateTimeNeonColor = Color.purple
								self.dateTimeBgColor = Color.black.opacity(0.75)
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
