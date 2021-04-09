import NomaePreferences
import SwiftUI

public struct TimeDateView: View {
	@Preference("dateFormat", identifier: ZinniaPreferences.identifier) public var dateFormat = "MM/dd/yyyy"
	@Preference("timeFormat", identifier: ZinniaPreferences.identifier) public var timeFormat = "hh:mm a"
	@Preference("dateTimeNeonMul", identifier: ZinniaPreferences.identifier) public var dateTimeNeonMul: Double = 1
	@Preference("dateTimeNeonColor", identifier: ZinniaPreferences.identifier) public var dateTimeNeonColor = Color.purple
	@Preference("dateTimeBgColor", identifier: ZinniaPreferences.identifier) public var dateTimeBgColor = Color.black

	@State var dateText: String = "4/9/2021"
	@State var timeText: String = "9:41 AM"

	var dateFormatter: DateFormatter
	var timeFormatter: DateFormatter

	let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

	public init() {
		self.dateFormatter = DateFormatter()
		self.timeFormatter = DateFormatter()
		self.dateFormatter.dateFormat = self.dateFormat
		self.timeFormatter.dateFormat = self.timeFormat
		self.updateTimeDate()
	}

	func updateTimeDate() {
		let currentDateTime = Date()
		self.dateText = self.dateFormatter.string(from: currentDateTime)
		self.timeText = self.timeFormatter.string(from: currentDateTime)
	}

	func BuildView() -> some View {
		VStack {
			Text(timeText).font(.largeTitle)
			Text(dateText).font(.callout)
		}
		.padding(8)
		.modifier(
			NeonEffect(
				base: RoundedRectangle(cornerRadius: 16, style: .continuous),
				color: self.dateTimeNeonColor,
				brightness: 0.1,
				innerSize: 1.5 * self.dateTimeNeonMul,
				middleSize: 3 * self.dateTimeNeonMul,
				outerSize: 5 * self.dateTimeNeonMul,
				innerBlur: 3,
				blur: 5
			)
		)
		.background(
			RoundedRectangle(cornerRadius: 16, style: .continuous)
				.foregroundColor(self.dateTimeBgColor)
		)
		.onReceive(self.timer) { _ in
			updateTimeDate()
		}
	}

	public var body: some View {
		BuildView()
	}
}
