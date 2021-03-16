import NetworkExtension
import SwiftUI
import ZinniaC

struct LockScreenView: View {
	@State private var anim_stroke_size = CGFloat(10.0)
	@State private var anim_faceid_alpha = 1.0

	init() {
		PDDokdo.sharedInstance()?.refreshWeatherData()
	}

	func WifiConnected() -> Bool {
		var strength = 0.0
		let semaphore = DispatchSemaphore(value: 0)
		NEHotspotNetwork.fetchCurrent { network in
			strength = network?.signalStrength ?? 0.0
			semaphore.signal()
		}
		switch semaphore.wait(timeout: DispatchTime(uptimeNanoseconds: 500_000_000)) {
		case .success:
			return strength > 0.0
		case .timedOut:
			return false
		}
	}

	func WeatherIcon() -> some View {
		guard let code = PDDokdo.sharedInstance().weatherWidget?.currentForecastModel().currentConditions.conditionCode,
		      let icon = WeatherInfo.codes[Int(code)]
		else {
			return AnyView(ZStack {
				Image(systemName: "cloud")
				Image(systemName: "questionmark").font(.system(size: 8))
			})
		}
		return AnyView(Image(systemName: icon))
	}

	@ViewBuilder func QuickGlanceView() -> some View {
		HStack {
			Spacer()
			WeatherIcon().padding(4.0)
			Image(systemName: WifiConnected() ? "wifi" : "wifi.slash").padding(4.0)
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

extension UIColor {
	static func blend(color1: UIColor, intensity1: CGFloat = 0.5, color2: UIColor,
	                  intensity2: CGFloat = 0.5) -> UIColor
	{
		let total = intensity1 + intensity2
		let l1 = intensity1 / total
		let l2 = intensity2 / total
		guard l1 > 0 else { return color2 }
		guard l2 > 0 else { return color1 }
		var (r1, g1, b1, a1): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
		var (r2, g2, b2, a2): (CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)

		color1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
		color2.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

		return UIColor(
			red: l1 * r1 + l2 * r2,
			green: l1 * g1 + l2 * g2,
			blue: l1 * b1 + l2 * b2,
			alpha: l1 * a1 + l2 * a2
		)
	}
}
