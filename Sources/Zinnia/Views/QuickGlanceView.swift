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
	@ObservedObject var globals = ZinniaSharedData.global

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
			temperature_color = UIColor.lerp(
				start: .systemBlue,
				end: .systemGreen,
				progress: CGFloat(capped_temperature) / 22
			)
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

	func WifiView() -> some View {
		let signal = self.globals.wifi_strength
		let icon = self.globals.associated ? "wifi" : "wifi.slash"
		var color = Color.red
		if self.globals.associated {
			switch signal {
			case 1:
				color = Color.red
			case 2:
				color = Color.orange
			case 3:
				color = Color.yellow
			case 4:
				color = Color.green
			default:
				break
			}
		}
		return Image(systemName: icon)
			.foregroundColor(color)
	}

	func MobileDataView() -> some View {
		let signal = self.globals.lte_strength
		let icon = self.globals.associated ? "chart.bar.fill" : "chart.bar"
		var color = Color.red
		if self.globals.associated {
			switch signal {
			case 1:
				color = Color.red
			case 2:
				color = Color.orange
			case 3:
				color = Color.yellow
			case 4:
				color = Color.green
			default:
				NSLog("Zinnia: Unexpected signal strength \(signal), should be 1-4")
			}
		}
		return Image(systemName: icon)
			.foregroundColor(color)
	}

	var body: some View {
		HStack {
			WeatherIcon().padding(4.0)
			WifiView().padding(4.0)
			MobileDataView().padding(4.0)
		}
	}
}
