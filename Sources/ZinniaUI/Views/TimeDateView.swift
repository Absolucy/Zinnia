import SwiftUI

public struct TimeDateView: View {
	static var dateFormatter: DateFormatter = {
		var fmt = DateFormatter()
		fmt.dateFormat = ZinniaPreferences.dateFormat
		return fmt
	}()

	static var timeFormatter: DateFormatter = {
		var fmt = DateFormatter()
		fmt.dateFormat = ZinniaPreferences.timeFormat
		return fmt
	}()

	public init() {}

	func BuildView() -> some View {
		let currentDateTime = Date()
		return VStack {
			VStack {
				Text(TimeDateView.timeFormatter.string(from: currentDateTime)).font(.largeTitle)
				Text(TimeDateView.dateFormatter.string(from: currentDateTime)).font(.callout)
			}
			.padding(8)
			.modifier(
				NeonEffect(
					base: RoundedRectangle(cornerRadius: 16, style: .continuous),
					color: ZinniaPreferences.dateTimeNeonColor,
					brightness: 0.1,
					innerSize: 1.5 * ZinniaPreferences.dateTimeNeonMul,
					middleSize: 3 * ZinniaPreferences.dateTimeNeonMul,
					outerSize: 5 * ZinniaPreferences.dateTimeNeonMul,
					innerBlur: 3,
					blur: 5
				)
			)
			.background(
				RoundedRectangle(cornerRadius: 16, style: .continuous)
					.foregroundColor(ZinniaPreferences.dateTimeBgColor)
					.opacity(ZinniaPreferences.dateTimeBgAlpha)
			)
		}
	}

	public var body: some View {
		BuildView()
	}
}
