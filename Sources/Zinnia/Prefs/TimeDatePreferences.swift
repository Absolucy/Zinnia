#if !THEOS_SWIFT
	// import NomaePreferences
#endif
import SwiftUI

internal enum SetFont: Identifiable {
	case date, time
	var id: Int { hashValue }
}

struct TimeDatePrefs: View {
	@Preference("dateFormat", identifier: ZinniaPreferences.identifier) var dateFormat = "MM/dd/yyyy"
	@Preference("dateFont", identifier: ZinniaPreferences.identifier) var dateFont = "San Fransisco"
	@Preference("dateFontSize", identifier: ZinniaPreferences.identifier) var dateFontSize = 16.0
	@Preference("timeFormat", identifier: ZinniaPreferences.identifier) var timeFormat = "hh:mm a"
	@Preference("timeFont", identifier: ZinniaPreferences.identifier) var timeFont = "San Fransisco"
	@Preference("timeFontSize", identifier: ZinniaPreferences.identifier) var timeFontSize = 34.0
	@Preference("dateTimeNeonMul", identifier: ZinniaPreferences.identifier) var dateTimeNeonMul: Double = 1
	@Preference("dateTimeNeonColor", identifier: ZinniaPreferences.identifier) var dateTimeNeonColor = Color.purple
	@Preference("dateTimeBgColor", identifier: ZinniaPreferences.identifier) var dateTimeBgColor = Color.black
		.opacity(0.75)

	@State private var confirmReset = false
	@Binding var setFont: SetFont?
	@Binding var dateFontInfo: UIFontDescriptor?
	@Binding var timeFontInfo: UIFontDescriptor?

	@ViewBuilder private func TimePreferences() -> some View {
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
		HStack {
			Text("Time Font")
			Spacer()
			Button(timeFont) {
				timeFontInfo = UIFontDescriptor(name: timeFont, size: CGFloat(timeFontSize))
				setFont = .time
			}
			Button(action: {
				timeFont = "San Fransisco"
			}) {
				Image(systemName: "arrow.counterclockwise.circle")
			}.padding(.leading, 5)
		}
		HStack {
			Text("Time Font Size")
			Text(String(format: "%.0fpt", timeFontSize))
				.font(.system(.caption, design: .monospaced))
			Spacer()
			Slider(value: $timeFontSize, in: 10.0 ... 48.0, step: 1)
			Button(action: {
				timeFontSize = 34.0
			}) {
				Image(systemName: "arrow.counterclockwise.circle")
			}.padding(.leading, 5)
		}
	}

	@ViewBuilder private func DatePreferences() -> some View {
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
			Text("Date Font")
			Spacer()
			Button(dateFont) {
				dateFontInfo = UIFontDescriptor(name: dateFont, size: CGFloat(dateFontSize))
				setFont = .date
			}
			Button(action: {
				dateFont = "San Fransisco"
			}) {
				Image(systemName: "arrow.counterclockwise.circle")
			}.padding(.leading, 5)
		}
		HStack {
			Text("Date Font Size")
			Text(String(format: "%.0fpt", dateFontSize))
				.font(.system(.caption, design: .monospaced))
			Spacer()
			Slider(value: $dateFontSize, in: 10.0 ... 48.0, step: 1)
			Button(action: {
				dateFontSize = 16.0
			}) {
				Image(systemName: "arrow.counterclockwise.circle")
			}.padding(.leading, 5)
		}
	}

	var body: some View {
		Section {
			TimeDateView()
				.padding()
				.border(Color.secondary)
			TimePreferences()
			DatePreferences()
			BasicNeonOptions(
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
								self.dateFont = "San Fransisco"
								self.dateFontSize = 16.0
								self.timeFormat = "hh:mm a"
								self.timeFont = "San Fransisco"
								self.timeFontSize = 34.0
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
