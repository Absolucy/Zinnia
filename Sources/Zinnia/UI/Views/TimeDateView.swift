import Combine
import SwiftUI

internal struct TimeDateView: View {
	@Preference("dateFormat", identifier: ZinniaPreferences.identifier) var dateFormat = "MM/dd/yyyy"
	@Preference("dateFont", identifier: ZinniaPreferences.identifier) var dateFont = "San Fransisco"
	@Preference("dateFontSize", identifier: ZinniaPreferences.identifier) var dateFontSize = 16.0
	@Preference("timeFormat", identifier: ZinniaPreferences.identifier) var timeFormat = "hh:mm a"
	@Preference("timeFont", identifier: ZinniaPreferences.identifier) var timeFont = "San Fransisco"
	@Preference("timeFontSize", identifier: ZinniaPreferences.identifier) var timeFontSize = 34.0
	@Preference("dateTimeNeonMul", identifier: ZinniaPreferences.identifier) private var dateTimeNeonMul: Double = 1
	@Preference("dateTimeNeonColor", identifier: ZinniaPreferences.identifier) private var dateTimeNeonColor = Color.purple
	@Preference("dateTimeBgColor", identifier: ZinniaPreferences.identifier) private var dateTimeBgColor = Color.black

	@State private var dateText: String = "4/9/2021"
	@State private var timeText: String = "9:41 AM"

	private var dateFormatter: DateFormatter
	private var timeFormatter: DateFormatter

	private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

	internal init() {
		dateFormatter = DateFormatter()
		timeFormatter = DateFormatter()
		dateFormatter.dateFormat = dateFormat
		timeFormatter.dateFormat = timeFormat
		updateTimeDate()
	}

	private func updateTimeDate() {
		let currentDateTime = Date()
		dateText = dateFormatter.string(from: currentDateTime)
		timeText = timeFormatter.string(from: currentDateTime)
	}

	private func BuildView() -> some View {
		VStack {
			Text(timeText)
				.font(.custom(timeFont, size: CGFloat(timeFontSize)))
				.minimumScaleFactor(0.001)
				.lineLimit(1)
			Text(dateText)
				.font(.custom(dateFont, size: CGFloat(dateFontSize)))
				.minimumScaleFactor(0.001)
				.lineLimit(1)
		}
		.padding(.vertical, 8)
		.padding(.horizontal, 24)
		.fixedSize()
		.modifier(
			NeonEffect(
				base: RoundedRectangle(cornerRadius: 16, style: .continuous),
				color: dateTimeNeonColor,
				brightness: 0.1,
				innerSize: 1.5 * dateTimeNeonMul,
				middleSize: 3 * dateTimeNeonMul,
				outerSize: 5 * dateTimeNeonMul,
				innerBlur: 3,
				blur: 5
			)
		)
		.background(
			RoundedRectangle(cornerRadius: 16, style: .continuous)
				.foregroundColor(dateTimeBgColor)
		)
		.onReceive(Just(dateFormat)) { newFormat in
			dateFormatter.dateFormat = newFormat
			updateTimeDate()
		}
		.onReceive(Just(timeFormat)) { newFormat in
			timeFormatter.dateFormat = newFormat
			updateTimeDate()
		}
		.onReceive(timer) { _ in
			updateTimeDate()
		}
	}

	internal var body: some View {
		if ZinniaDRM.ticketAuthorized() {
			BuildView()
		} else {
			EmptyView()
		}
	}
}
