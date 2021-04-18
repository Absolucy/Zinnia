import Foundation
#if !THEOS_SWIFT
	import NomaePreferences
#endif
import CoreGraphics
import SwiftUI
import ZinniaC

struct PreferencesView: View {
	@Environment(\.colorScheme) var colorScheme

	@State var fullPreview = false
	@State var respringAlert = false
	@Preference("enabled", identifier: ZinniaPreferences.identifier) var enabled = true

	let lockScreenBg: AnyView = {
		if let bg = lockScreenWallpaper() {
			return AnyView(Image(uiImage: bg))
		} else {
			return AnyView(Color.primary.colorInvert())
		}
	}()

	var body: some View {
		ScrollView {
			VStack {
				Header("Zinnia",
				       icon: (Image(contentsOfFile: "/Library/PreferenceBundles/ZinniaPrefs.bundle/zinnia.png") ??
				       	Image(systemName: "lock.rectangle.stack")).resizable().frame(width: 50, height: 50))
				Toggle("Enabled", isOn: $enabled)
					.onTapGesture {
						respringAlert = true
					}
					.alert(isPresented: $respringAlert) {
						Alert(
							title: Text("In order for Zinnia to be enabled/disabled, you need to respring. Would you like to do so now?"),
							primaryButton: .destructive(Text("Respring")) {
								var pid: pid_t = 0
								posix_spawn(&pid, "/usr/bin/sbreload", nil, nil, [nil], nil)
							},
							secondaryButton: .cancel(Text("Later"))
						)
					}
				if self.enabled {
					Button("Full Preview") {
						fullPreview = true
					}
					Divider().padding()
					TimeDatePrefs()
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
		.fullScreenCover(isPresented: $fullPreview) {
			VStack {
				TimeDateView()
					.padding(.vertical, 30)
				Spacer().allowsHitTesting(false)
				Text("Unlock to exit preview")
					.font(.caption)
				UnlockButtonView(unlock: {
					fullPreview = false
				}, camera: {})
			}
			.preferredColorScheme(self.colorScheme)
			.background(lockScreenBg)
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
