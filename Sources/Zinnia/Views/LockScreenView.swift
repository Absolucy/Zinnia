import SwiftUI
import ZinniaC

struct LockScreenView: View {
	@State private var anim_stroke_size = CGFloat(10.0)
	@State private var anim_faceid_alpha = 1.0

	init() {
		PDDokdo.sharedInstance()?.refreshWeatherData()
	}

	func WeatherIcon() -> some View {
		#if targetEnvironment(simulator)
			let temperature = Int.random(in: 0 ... 38)
			let icon = "cloud.fill"
		#else
			guard let dokdo = PDDokdo.sharedInstance(), let model = dokdo.weatherWidget?.currentForecastModel(),
			      let icon = WeatherInfo.codes[Int(model.currentConditions.conditionCode)]
			else {
				return AnyView(ZStack {
					Image(systemName: "cloud")
					Image(systemName: "questionmark").font(.system(size: 8))
				})
			}
			guard let temperature_string = dokdo.currentTemperature,
			      let temperature = Int(temperature_string.replacingOccurrences(of: "°", with: ""))
			else {
				return AnyView(Image(systemName: icon))
			}
		#endif
		var temperature_color: UIColor
		// Room temperature
		if temperature >= 20 && temperature <= 22 {
			temperature_color = .systemGreen
			// Above room temperature
		} else if temperature > 22 {
			// Cap at around 38C / 100F
			let capped_temperature = CGFloat(min(temperature, 38)) - 16
			temperature_color = UIColor.lerp(start: .systemGreen, end: .systemRed, progress: capped_temperature / 22)
			// Below room temperature
		} else {
			let capped_temperature = CGFloat(max(temperature, 0))
			temperature_color = UIColor.lerp(start: .systemBlue, end: .systemGreen, progress: capped_temperature / 22)
		}
		return AnyView(Image(systemName: icon).foregroundColor(Color(temperature_color)))
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

	@ViewBuilder func QuickGlanceView() -> some View {
		HStack {
			Spacer()
			WeatherIcon().padding(4.0)
			WifiView().padding(4.0)
			MobileDataView().padding(4.0)
			Spacer()
		}
	}

	private static var gradient_start = Color.pink
	private static var gradient_end = Color(
		UIColor.blend(
			color1: .systemPink,
			color2: .white
		)
	)

	@ViewBuilder func UnlockButtonView(_ frame: GeometryProxy) -> some View {
		Group {
			Text("Tap to unlock")
			HStack {
				Spacer()
				Circle()
					.frame(width: frame.size.width * 0.25, height: frame.size.width * 0.25)
					.foregroundColor(.primary)
					.overlay(
						Circle()
							.stroke(
								LinearGradient(
									gradient: Gradient(colors: [Self.gradient_start, Self.gradient_end]),
									startPoint: /*@START_MENU_TOKEN@*/ .leading/*@END_MENU_TOKEN@*/,
									endPoint: /*@START_MENU_TOKEN@*/ .trailing/*@END_MENU_TOKEN@*/
								),
								lineWidth: anim_stroke_size
							)
							.animation(Animation.easeInOut.repeatForever().speed(0.25))
							.overlay(
								Image(systemName: "faceid")
									.foregroundColor(.accentColor)
									.opacity(anim_faceid_alpha)
									.animation(Animation.easeInOut.repeatForever().speed(0.25))
									.font(.system(size: 60))
									.scaledToFit()
									.padding()
									.onAppear(perform: {
										self.anim_faceid_alpha = 0.0
									})
							)
							.onAppear(perform: {
								anim_stroke_size = 5.0
							})
					)
					.padding()
					.onTapGesture {
						// TODO: unlock here
					}
				Spacer()
			}
		}
	}

	var body: some View {
		GeometryReader { frame in
			ZStack {
				Rectangle().foregroundColor(.purple)
				VStack {
					Text("10:42 PM").font(.largeTitle).padding()
					QuickGlanceView()
					Spacer()
					UnlockButtonView(frame)
				}
			}
		}
	}
}

struct LockScreenView_Previews: PreviewProvider {
	static var previews: some View {
		LockScreenView()
			.preferredColorScheme(.dark)
			.previewLayout(.device)
			.previewDevice("iPhone 11")
		LockScreenView()
			.preferredColorScheme(.dark)
			.previewLayout(.device)
			.previewDevice("iPad (8th generation)")
	}
}
