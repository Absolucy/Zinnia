import Foundation
#if !THEOS_SWIFT
	import NomaePreferences
	import ZinniaUI
#endif
import SwiftUI

struct PreferencesView: View {
	@Environment(\.colorScheme) var colorScheme

	@State var fullPreview = false
	@Preference("enabled", identifier: ZinniaPreferences.identifier) var enabled = true

	var body: some View {
		ScrollView {
			VStack {
				Header("Zinnia",
				       icon: (Image(contentsOfFile: "/Library/PreferenceBundles/ZinniaPrefs.bundle/zinnia.png") ??
				       	Image(systemName: "lock.rectangle.stack")).resizable().frame(width: 50, height: 50))
				Toggle("Enabled", isOn: $enabled)
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
					Divider().padding()
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
			.background(Color.primary.colorInvert())
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
