//  Copyright (c) 2021 Lucy <lucy@absolucy.moe>
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at http://mozilla.org/MPL/2.0/.

import Combine
import SwiftUI

internal struct TimeDateView: View {
	@ObservedObject private var globals = SharedData.instance

	@Preference("dateFormat", identifier: ZinniaPreferences.identifier) var dateFormat = "MM/dd/yyyy"
	@Preference("dateFont", identifier: ZinniaPreferences.identifier) var dateFont = "San Fransisco"
	@Preference("dateFontSize", identifier: ZinniaPreferences.identifier) var dateFontSize = 16.0
	@Preference("timeFormat", identifier: ZinniaPreferences.identifier) var timeFormat = "hh:mm a"
	@Preference("timeFont", identifier: ZinniaPreferences.identifier) var timeFont = "San Fransisco"
	@Preference("timeFontSize", identifier: ZinniaPreferences.identifier) var timeFontSize = 34.0
	@Preference("dateTimeEnabled", identifier: ZinniaPreferences.identifier) var dateTimeEnabled = true
	@Preference("dateTimeNeonMul", identifier: ZinniaPreferences.identifier) private var dateTimeNeonMul: Double = 1
	@Preference("dateTimeNeonColor", identifier: ZinniaPreferences.identifier) private var dateTimeNeonColor = Color.purple
	@Preference("dateTimeBgColor", identifier: ZinniaPreferences.identifier) private var dateTimeBgColor = Color.black
	@Preference("dateTimePadding", identifier: ZinniaPreferences.identifier) private var dateTimePadding: Double = 8

	private var dateFormatter: DateFormatter
	private var timeFormatter: DateFormatter

	internal init() {
		dateFormatter = DateFormatter()
		timeFormatter = DateFormatter()
		dateFormatter.dateFormat = dateFormat
		timeFormatter.dateFormat = timeFormat
	}

	private func BuildView() -> some View {
		VStack {
			if !dateTimeEnabled {
				EmptyView()
			} else {
				VStack {
					Text(timeFormatter.string(from: globals.dateTime))
						.font(.custom(timeFont, size: CGFloat(timeFontSize)))
						.minimumScaleFactor(0.001)
						.lineLimit(1)
					Text(dateFormatter.string(from: globals.dateTime))
						.font(.custom(dateFont, size: CGFloat(dateFontSize)))
						.minimumScaleFactor(0.001)
						.lineLimit(1)
				}
				.padding(.vertical, CGFloat(dateTimePadding))
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
				}
				.onReceive(Just(timeFormat)) { newFormat in
					timeFormatter.dateFormat = newFormat
				}
			}
		}
	}

	internal var body: some View {
		BuildView()
	}
}
