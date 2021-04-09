import Foundation
import NomaePreferences
import SwiftUI
import ZinniaUI

struct PreferencesView: View {
	@Environment(\.colorScheme) var colorScheme

	@State var fullPreview = false
	@Preference("enabled", identifier: ZinniaPreferences.identifier) var enabled = true

	var body: some View {
		VStack {
			Toggle("Enabled", isOn: $enabled)
			if self.enabled {
				Button("Full Preview") {
					fullPreview = true
				}
				ScrollView {
					VStack {
						Divider().padding()
						TimeDatePrefs()
						Divider().padding()
						UnlockPrefs()
						Divider().padding()
						PopupPrefs()
						Divider().padding()
					}
				}
			}
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
