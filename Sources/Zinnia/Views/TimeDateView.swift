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
			}.padding(.top)
		}
	}

	var body: some View {
		BuildView()
	}
}
