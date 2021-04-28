import CoreGraphics
import Foundation
import SwiftUI
import ZinniaC

struct PreferencesView: View {
	@Environment(\.colorScheme) var colorScheme

	@State private var fullPreview = false
	@State private var respringAlert = false
	@State private var setFont: SetFont? = nil
	@State private var dateFontInfo: UIFontDescriptor? = nil
	@State private var timeFontInfo: UIFontDescriptor? = nil

	@Preference("enabled", identifier: ZinniaPreferences.identifier) var enabled = true
	@Preference("dateFont", identifier: ZinniaPreferences.identifier) var dateFont = "San Fransisco"
	@Preference("timeFont", identifier: ZinniaPreferences.identifier) var timeFont = "San Fransisco"

	let lockScreenBg: AnyView = {
		if let bg = lockScreenWallpaper() {
			return AnyView(Image(uiImage: bg))
		} else {
			return AnyView(Color.primary.colorInvert())
		}
	}()

	var body: some View {
		ZStack {
			ScrollView {
				VStack {
					Header("Zinnia",
					       icon: (Image(contentsOfFile: "/Library/PreferenceBundles/ZinniaPrefs.bundle/icon-logo.png") ??
					       	Image(systemName: "lock.rectangle.stack")).resizable().frame(width: 120, height: 120))
					Toggle("Enabled", isOn: $enabled)
						.onTapGesture {
							respringAlert = true
						}
						.alert(isPresented: $respringAlert) {
							Alert(
								title: Text("In order for Zinnia to be enabled/disabled, you need to respring. Would you like to do so now?"),
								primaryButton: .destructive(Text("Respring"), action: respring),
								secondaryButton: .cancel(Text("Later"))
							)
						}
					if self.enabled {
						Button("Full Preview") {
							fullPreview = true
						}
						Divider().padding()
						TimeDatePrefs(setFont: $setFont, dateFontInfo: $dateFontInfo, timeFontInfo: $timeFontInfo)
						Divider().padding()
						UnlockPrefs()
						Divider().padding()
						PopupPrefs()
					}
					Divider().padding()
					HStack {
						TwitterLogo().frame(width: 24, height: 24).padding(.trailing)
						Button("Tweak by Aspen") {
							let appURL = URL(string: "twitter://user?screen_name=aspenluxxxy")!
							let webURL = URL(string: "https://twitter.com/aspenluxxxy")!

							let application = UIApplication.shared

							if application.canOpenURL(appURL as URL) {
								application.open(appURL as URL)
							} else {
								application.open(webURL as URL)
							}
						}
					}
				}.padding(.horizontal)
			}
			.padding()

			EmptyView().sheet(item: $setFont, onDismiss: {
				if let dateFontInfo = self.dateFontInfo {
					dateFont = dateFontInfo.postscriptName
				}
				if let timeFontInfo = self.timeFontInfo {
					timeFont = timeFontInfo.postscriptName
				}
			}, content: { f in
				switch f {
				case .date:
					FontPicker(font: $dateFontInfo).padding(.top)
				case .time:
					FontPicker(font: $timeFontInfo).padding(.top)
				}
			})

			EmptyView().fullScreenCover(isPresented: $fullPreview) {
				VStack {
					TimeDateView()
						.padding(.vertical, 30)
					Spacer().allowsHitTesting(false)
					Text("Unlock to exit preview")
						.font(.caption)
					UnlockButtonView()
				}
				.preferredColorScheme(self.colorScheme)
				.background(lockScreenBg)
			}
		}
	}
}

struct PreferencesViewPreviews: PreviewProvider {
	static var previews: some View {
		PreferencesView()
			.preferredColorScheme(.dark)
		PreferencesView()
			.preferredColorScheme(.light)
	}
}

private extension Image {
	init?(contentsOfFile path: String) {
		guard let uiImage = UIImage(contentsOfFile: path) else { return nil }
		self.init(uiImage: uiImage)
	}
}
