import SwiftUI

struct TimeDateView: View {
	func BuildView() -> some View {
		let current_datetime = Date()
		let date_fmt = DateFormatter()
		date_fmt.dateFormat = "hh:mm a"
		let time = date_fmt.string(from: current_datetime)
		date_fmt.dateFormat = "MM/dd/yyyy"
		let date = date_fmt.string(from: current_datetime)

		return VStack {
			VStack {
				Text(time).font(.largeTitle)
				Text(date).font(.callout)
			}
			.padding(8)
			.modifier(
				NeonEffect(
					base: RoundedRectangle(cornerRadius: 16, style: .continuous),
					color: Color.purple,
					brightness: 0.1,
					innerSize: 1.5,
					middleSize: 3,
					outerSize: 5,
					innerBlur: 3,
					blur: 5
				)
			)
			.background(
				RoundedRectangle(cornerRadius: 16, style: .continuous)
					.foregroundColor(.black)
					.opacity(0.25)
			)
		}
	}

	var body: some View {
		BuildView()
	}
}
