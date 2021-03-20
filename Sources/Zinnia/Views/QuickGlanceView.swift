//
//  QuickInfoView.swift
//
//
//  Created by Aspen on 3/18/21.
//

import Foundation
import SwiftUI
import UIKit
import ZinniaC

struct QuickGlanceView: View {
	init() {
		PDDokdo.sharedInstance()?.refreshWeatherData()
	}

	func WeatherIcon() -> some View {
		#if targetEnvironment(simulator)
			let temperature = 38
			let icon_name = WeatherInfo.codes[Int.random(in: 0 ... 47)]!
		#else
			guard let dokdo = PDDokdo.sharedInstance(), let model = dokdo.weatherWidget?.currentForecastModel(),
			      let icon_name = WeatherInfo.codes[Int(model.currentConditions.conditionCode)]
			else {
				return AnyView(ZStack {
					Image(systemName: "cloud")
					Image(systemName: "questionmark").font(.system(size: 8))
				})
			}
			guard let temperature_string = dokdo.currentTemperature,
			      let temperature = Int(temperature_string.replacingOccurrences(of: "°", with: ""))
			else {
				return AnyView(Image(systemName: icon_name))
			}
		#endif
		var temperature_color: UIColor
		let capped_temperature = min(max(temperature, 0), 38)
		switch capped_temperature {
		case Int.min ..< 20: // Cold temperatures
			temperature_color = UIColor.lerp(
				start: .systemGreen,
				end: .systemRed,
				progress: (CGFloat(capped_temperature) - 16) / 22
			)
		case 20 ... 22: // Room temperature
			temperature_color = .systemGreen
		case 22 ... Int.max: // Hot temperatures
			temperature_color = UIColor.lerp(start: .systemBlue, end: .systemGreen, progress: CGFloat(capped_temperature) / 22)
		default:
			return AnyView(ZStack {
				Image(systemName: "cloud")
				Image(systemName: "questionmark").font(.system(size: 8))
			})
		}
		return AnyView(
			UIImage(systemName: icon_name).map { icon in
				Image(uiImage: UIImage(systemName: icon_name + ".fill") ?? icon)
					.renderingMode(.template)
					.foregroundColor(Color(temperature_color))
			}
		)
	}

	@ViewBuilder func WifiView() -> some View {
		let signal = NetworkStatus.WifiSignal()
		let icon = signal > 0.25 ? "wifi" : (signal > 5 ? "wifi.exclamationmark" : "wifi.slash")
		let color = signal > 0.5 ?
			UIColor.lerp(start: UIColor.yellow, end: UIColor.green, progress: CGFloat(signal)) :
			(signal <= 0.01 ? UIColor.gray : UIColor
				.lerp(start: UIColor.red, end: UIColor.yellow, progress: CGFloat(signal)))
		Image(systemName: icon)
			.foregroundColor(Color(color))
	}

	@ViewBuilder func MobileDataView() -> some View {
		let signal = NetworkStatus.MobileSignal()
		let icon = signal > 0.5 ? "chart.bar.fill" : "chart.bar"
		let color = signal > 0.5 ?
			UIColor.lerp(start: UIColor.yellow, end: UIColor.green, progress: CGFloat(signal)) :
			(signal <= 0.01 ? UIColor.gray : UIColor
				.lerp(start: UIColor.red, end: UIColor.yellow, progress: CGFloat(signal)))
		ZStack {
			Image(systemName: icon)
				.foregroundColor(Color(color))
		}
	}

	var body: some View {
		HStack {
			WeatherIcon().padding(4.0)
			WifiView().padding(4.0)
			MobileDataView().padding(4.0)
		}
	}
}
